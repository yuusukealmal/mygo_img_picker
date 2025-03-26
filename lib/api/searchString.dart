import 'dart:convert';
import 'dart:io';
import 'package:mygo_img_picker/api/getJsonFile.dart';
import 'package:mygo_img_picker/class/content.dart';

Future<List<MYGO>> getKeyword(String keyword) async {
  final File f = await getJsonFile();
  final String jsonString = f.readAsStringSync();
  final List<dynamic> data = jsonDecode(jsonString);

  final cleanKeyword = keyword.replaceAll(" ", "");

  final List<MYGO> res = data
      .where((element) {
        if (cleanKeyword.isEmpty) {
          return true;
        } else {
          return element["text"].contains(keyword);
        }
      })
      .map((element) {
        return MYGO(
          text: element["text"],
          season: element["season"],
          episode: element["episode"],
          frameStart: element["frame_start"],
          framePrefer: element["frame_prefer"],
          frameEnd: element["frame_end"],
          segmentID: element["segment_id"],
          characterID: element["character"],
        );
      })
      .toList();

  return res;
}