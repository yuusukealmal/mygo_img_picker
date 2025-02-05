import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key, required this.hash});

  final String hash;

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  static const MethodChannel _updateChannel = MethodChannel("com.mygo/update");
  static const MethodChannel _progressChannel =
      MethodChannel("com.mygo/progress");

  static const String _apkUrl =
      "https://github.com/yuusukealmal/mygo_img_picker/releases/latest/download/app-release.apk";

  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    _progressChannel.setMethodCallHandler((call) async {
      if (call.method == "updateProgress") {
        int progress = call.arguments as int;
        if (progress >= 0 && progress <= 100) {
          setState(() {
            _progress = progress / 100.0;
          });
        }
      }
    });

    startDownload();
  }

  Future<void> startDownload() async {
    try {
      await _updateChannel.invokeMethod("updateAPK", {"apkUrl": _apkUrl});
    } on PlatformException catch (e) {
      debugPrint("Error: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("APK Downloader")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  "Downloading Mygo Image Picker with version ${widget.hash.substring(0, 7)}..."),
              SizedBox(height: 20),
              LinearProgressIndicator(value: _progress),
              SizedBox(height: 20),
              Text("${(_progress * 100).toInt()}%")
            ],
          ),
        ),
      ),
    );
  }
}
