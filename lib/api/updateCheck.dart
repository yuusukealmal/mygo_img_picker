import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

Future<String> isLatest() async {
  final response = await http.get(Uri.parse(
      'https://raw.githubusercontent.com/yuusukealmal/mygo_img_picker/refs/heads/main/version/version.json'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final remoteversion = data['hash'];
    final localversionfile =
        await rootBundle.loadString('version/version.json');
    final localversion = jsonDecode(localversionfile)['hash'];
    debugPrint("remote: $remoteversion, local: $localversion");
    return remoteversion == localversion ? "" : remoteversion;
  } else {
    return "";
  }
}
