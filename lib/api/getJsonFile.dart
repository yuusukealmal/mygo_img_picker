import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<File> getJsonFile() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  File f = File("${directory.path}/data.json");
  return f;
}
