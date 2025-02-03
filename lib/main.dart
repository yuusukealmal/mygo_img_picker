import 'package:flutter/material.dart';
import 'package:mygo_img_picker/pages/FloatingBall.dart';

void main() async {
  // await getKeyword("愛音");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movable Floating Ball',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FloatingBall(),
    );
  }
}
