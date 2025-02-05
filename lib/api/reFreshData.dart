import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mygo_img_picker/api/getJsonFile.dart';

Future<String> reFreshData() async {
  try {
    http.Response req = await http.get(Uri.parse(
        "https://raw.githubusercontent.com/Its-MyPic/Its-MyPicDB/refs/heads/json/data.json"));
    String content = req.body;
    File f = await getJsonFile();
    await f.writeAsString(content);
    return "Success Refresh data.json !";
  } catch (e) {
    return e.toString();
  }
}
