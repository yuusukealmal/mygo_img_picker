class MYGO {
  MYGO(
      {required this.text,
      required this.season,
      required this.episode,
      required this.frameStart,
      required this.framePrefer,
      required this.frameEnd,
      required this.segmentID,
      required this.characterID});

  String text;
  int season;
  int episode;
  int frameStart;
  int framePrefer;
  int frameEnd;
  int segmentID;
  int characterID;

  String ImgURL() {
    return "https://mypic.0m0.uk/images/$season/$episode/$framePrefer.jpg";
  }
}
