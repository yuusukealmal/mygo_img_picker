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
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import androidx.core.content.FileProvider
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import java.net.URL
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.mygo/clipboard"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        MethodChannel(flutterEngine!!.dartExecutor, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "copyImage") {
                val imageUrl = call.argument<String>("imageUrl")
                if (imageUrl != null) {
                    GlobalScope.launch {  // Run the image download in a coroutine
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
    }

    private suspend fun getBitmapFromURL(imageUrl: String): Bitmap? {
        return withContext(Dispatchers.IO) {  // Switch to IO thread
            try {
                val url = URL(imageUrl)
                val connection = url.openConnection()
                connection.connect() // Make sure the connection is successful
    
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
        // Create a file in external storage
        val file = File(getExternalFilesDir(null), "image_to_copy.png")
        FileOutputStream(file).use {
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, it)
        }
    
        // Get the URI for the file using FileProvider
        return FileProvider.getUriForFile(this, "com.example.mygo_img_picker.provider", file)
    }
    

    private fun copyImageToClipboard(imageUri: Uri) {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newUri(contentResolver, "Image", imageUri)
    
        // Grant URI permissions
        val flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
        grantUriPermission("com.example.mygo_img_picker", imageUri, flags)
    
        clipboard.setPrimaryClip(clip)
    }
    
}
