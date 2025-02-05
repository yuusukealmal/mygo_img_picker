package com.example.mygo_img_picker

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Bundle
import android.os.Environment
import androidx.core.content.FileProvider
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import java.net.HttpURLConnection
import java.net.URL
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity: FlutterActivity() {
    private val CLICKBOARD_CHANNEL = "com.mygo/clipboard"
    private val UPDATE_CHANNEL = "com.mygo/update"

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    
        if (requestCode == 1001) {
            println(grantResults.contentToString())
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                println("Storage permission granted!")
            } else {
                println("Storage permission denied!")
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.Q) {
            if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.WRITE_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, 
                    arrayOf(android.Manifest.permission.WRITE_EXTERNAL_STORAGE), 1001)
            }
        }

        MethodChannel(flutterEngine!!.dartExecutor, CLICKBOARD_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "copyImage") {
                val imageUrl = call.argument<String>("imageUrl")
                if (imageUrl != null) {
                    GlobalScope.launch {
                        try {
                            val bitmap = getBitmapFromURL(imageUrl)
                            if (bitmap != null) {
                                val imageUri = saveImageToFile(bitmap)
                                copyImageToClipboard(imageUri)
                                result.success("Image copied to clipboard!")
                            } else {
                                result.error("UNAVAILABLE", "Image could not be loaded.", null)
                            }
                        } catch (e: Exception) {
                            result.error("UNAVAILABLE", "Image could not be loaded: ${e.message}", null)
                        }
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "URL cannot be null.", null)
                }
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine!!.dartExecutor, UPDATE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateAPK") {
                val apkUrl = call.argument<String>("apkUrl")
                if (apkUrl != null) {
                    GlobalScope.launch {
                        try {
                            downloadUpdateAPK(apkUrl, result)
                        } catch (e: Exception) {
                            result.error("INSTALL_FAILED", "Failed to install APK: ${e.message}", null)
                        }
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "URL cannot be null.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private suspend fun getBitmapFromURL(imageUrl: String): Bitmap? {
        return withContext(Dispatchers.IO) {
            try {
                val url = URL(imageUrl)
                val connection = url.openConnection()
                connection.connect()

                val inputStream: InputStream = connection.getInputStream()
                val bitmap = BitmapFactory.decodeStream(inputStream)

                bitmap
            } catch (e: Exception) {
                println("Error downloading or decoding image: ${e.message}")
                e.printStackTrace()
                null
            }
        }
    }

    private fun saveImageToFile(bitmap: Bitmap): Uri {
        val file = File(getExternalFilesDir(null), "cache.png")
        FileOutputStream(file).use { bitmap.compress(Bitmap.CompressFormat.PNG, 100, it) }

        return FileProvider.getUriForFile(this, "com.mygo_img_picker.provider", file)
    }

    private fun copyImageToClipboard(imageUri: Uri) {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newUri(contentResolver, "Image", imageUri)
        val flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
        grantUriPermission("com.example.mygo_img_picker", imageUri, flags)

        clipboard.setPrimaryClip(clip)
    }

    private fun downloadUpdateAPK(apkUrl: String, result: MethodChannel.Result) {
        if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.Q) {
            if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.WRITE_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(
                    this, arrayOf(android.Manifest.permission.WRITE_EXTERNAL_STORAGE), 1001
                )
                return
            }
        }
    
        val progressChannel = MethodChannel(flutterEngine!!.dartExecutor, "com.mygo/progress")
    
        GlobalScope.launch {
            try {
                val file = downloadApk(apkUrl, progressChannel)
                if (file != null) {
                    installApk(file)
                    result.success("APK installed successfully!")
                } else {
                    result.error("DOWNLOAD_FAILED", "Failed to download APK.", null)
                }
            } catch (e: Exception) {
                result.error("INSTALL_FAILED", "Failed to install APK: ${e.message}", null)
            }
        }
    }

    private suspend fun downloadApk(apkUrl: String, progressChannel: MethodChannel): File? {
        return withContext(Dispatchers.IO) {
            try {
                val url = URL(apkUrl)
                val connection = url.openConnection() as HttpURLConnection
                connection.connect()
    
                val fileSize = connection.contentLength
                if (fileSize <= 0) {
                    withContext(Dispatchers.Main) {
                        progressChannel.invokeMethod("updateProgress", 100)
                    }
                }
    
                val inputStream: InputStream = connection.inputStream
                val file = File(getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS), "update.apk")
                val outputStream = FileOutputStream(file)
    
                val buffer = ByteArray(4096)
                var len: Int
                var downloaded: Long = 0
    
                while (inputStream.read(buffer).also { len = it } > 0) {
                    outputStream.write(buffer, 0, len)
                    downloaded += len
                    val progress = (downloaded * 100 / fileSize).toInt()
    
                    withContext(Dispatchers.Main) {
                        progressChannel.invokeMethod("updateProgress", progress)
                    }
                }
    
                outputStream.flush()
                outputStream.close()
                inputStream.close()
    
                file
            } catch (e: Exception) {
                e.printStackTrace()
                withContext(Dispatchers.Main) {
                    progressChannel.invokeMethod("updateProgress", -1) // Send error code
                }
                null
            }
        }
    }
    

    private fun installApk(file: File) {
        val apkUri: Uri = FileProvider.getUriForFile(this, "com.mygo_img_picker.provider", file)
        val intent = Intent(Intent.ACTION_VIEW)
        intent.setDataAndType(apkUri, "application/vnd.android.package-archive")
        intent.flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
        startActivity(intent)
    }
}
