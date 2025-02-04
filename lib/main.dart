import 'package:flutter/material.dart';
import 'package:mygo_img_picker/pages/MyHomePage.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Mygo Image Picker'),
    );
  }
}
