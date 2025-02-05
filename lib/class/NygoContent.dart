class MYGO {
  MYGO(
      {required this.text,
      required this.episode,
      required this.frameStart,
      required this.frameEnd,
      required this.segmentID});

  String text;
  String episode;
  int frameStart;
  int frameEnd;
  int segmentID;

  String ImgURL() {
    return "https://mygodata.0m0.uk/images/${episode}_$frameStart.jpg";
  }
}
