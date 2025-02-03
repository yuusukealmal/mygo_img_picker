import 'package:flutter/material.dart';
import 'package:mygo_img_picker/api/imgDownload.dart';
import 'package:mygo_img_picker/api/searchString.dart';
import 'package:mygo_img_picker/class/content.dart';

class FloatingBall extends StatefulWidget {
  const FloatingBall({super.key});

  @override
  State<FloatingBall> createState() => _FloatingBallState();
}

class _FloatingBallState extends State<FloatingBall> {
  Offset _position = Offset(100, 100);
  bool _showPopup = false;
  final TextEditingController _searchController = TextEditingController();
  List<MYGO> _keywords = [];

  void _updatePosition(Offset newPosition) {
    setState(() {
      _position = newPosition;
    });
  }

  void _togglePopup() {
    setState(() {
      _showPopup = !_showPopup;
    });
  }

  bool _isTouching(Offset ball, Size ballSize, Size popupSize) {
    double popupX = MediaQuery.of(context).size.width / 2;
    double popupY = MediaQuery.of(context).size.height / 2;

    double popupLeft = popupX - popupSize.width / 2;
    double popupRight = popupX + popupSize.width / 2;
    double popupTop = popupY - popupSize.height / 2;
    double popupBottom = popupY + popupSize.height / 2;

    double ballLeft = ball.dx;
    double ballRight = ball.dx + ballSize.width;
    double ballTop = ball.dy;
    double ballBottom = ball.dy + ballSize.height;

    return ballLeft < popupRight &&
        ballRight > popupLeft &&
        ballTop < popupBottom &&
        ballBottom > popupTop;
  }

  void _search() async {
    List<MYGO> result = await getKeyword(_searchController.text);
    setState(() {
      _keywords = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Size ballSize = Size(60, 60);
    Size popupSize = Size(screenWidth * 0.9, screenHeight * 0.9);
    bool isTouching = _isTouching(_position, ballSize, popupSize);

    if (_showPopup && isTouching) {
      _position = Offset(0, _position.dy);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Movable Floating Ball'),
      ),
      body: Stack(
        children: [
          Positioned(
            left: _position.dx,
            top: _position.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                _updatePosition(Offset(
                  _position.dx + details.delta.dx,
                  _position.dy + details.delta.dy,
                ));
              },
              onTap: _togglePopup,
              child: Container(
                width: ballSize.width,
                height: ballSize.height,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.touch_app,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          if (_showPopup)
            Center(
              child: Container(
                width: popupSize.width,
                height: popupSize.height,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search,
                            color: Theme.of(context).iconTheme.color),
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      ),
                      onChanged: (value) {
                        _search();
                      },
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: _keywords.isEmpty
                          ? Center(child: Text("No results"))
                          : GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                              itemCount: _keywords.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  color: Colors.white,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween, // Space items evenly
                                    children: [
                                      // Image in the middle
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            await downloadImage(context,
                                                _keywords[index].ImgURL());
                                          },
                                          child: Image.network(
                                            _keywords[index].ImgURL(),
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      // Text at the bottom
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8),
                                        child: Text(
                                          _keywords[index].text,
                                          style: TextStyle(color: Colors.black),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _togglePopup,
                      child: Text('Close'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
