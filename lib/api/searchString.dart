import 'dart:convert';
import 'dart:io';
import 'package:mygo_img_picker/api/getJsonFile.dart';
import 'package:mygo_img_picker/class/content.dart';

Future<List<MYGO>> getKeyword(String keyword) async {
  List<MYGO> res = [];
  if (keyword.replaceAll(" ", "") == "") return res;
  File f = await getJsonFile();
  String jsonString = f.readAsStringSync();
  final data = jsonDecode(jsonString);
  data.forEach((element) {
    if (element["text"].contains(keyword)) {
      MYGO mygo = MYGO(
        text: element["text"],
        episode: element["episode"],
        frameStart: element["frame_start"],
        frameEnd: element["frame_end"],
        segmentID: element["segment_id"],
      );
      res.add(mygo);
    }
  });
  return res;
}
