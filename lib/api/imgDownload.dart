import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> downloadImage(BuildContext context, String imageUrl) async {
  const platform = MethodChannel('com.mygo/clipboard');
  try {
    final String result =
        await platform.invokeMethod('copyImage', {'imageUrl': imageUrl});
    debugPrint(result);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image copied to clipboard!')),
    );
  } on PlatformException catch (e) {
    debugPrint("Failed to copy image: ${e.message}");
  }
}
