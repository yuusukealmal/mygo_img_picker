import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mygo_img_picker/class/NygoContent.dart';

Future<List<MYGO>> getKeyword(String keyword) async {
  if (keyword.replaceAll(" ", "") == "") return [];
  List<MYGO> res = [];
  final jsonString = await rootBundle.loadString('assets/data.json');
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
