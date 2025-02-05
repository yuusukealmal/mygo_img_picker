import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mygo_img_picker/api/getJsonFile.dart';
import 'package:mygo_img_picker/api/imgDownload.dart';
import 'package:mygo_img_picker/api/reFreshData.dart';
import 'package:mygo_img_picker/api/searchString.dart';
import 'package:mygo_img_picker/class/content.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<MYGO> _keywords = [];
  final TextEditingController _searchController = TextEditingController();

  void _search() async {
    List<MYGO> result = await getKeyword(_searchController.text);
    setState(() {
      _keywords = result;
    });
  }

  Future<void> _checkifNull() async {
    File f = await getJsonFile();
    if (await f.exists() == false) {
      await reFreshData();
    }
  }

  @override
  void initState() {
    super.initState();
    _checkifNull();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color.fromARGB(101, 162, 35, 201),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              String res = await reFreshData();
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(res)));
            },
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              width: screenWidth,
              height: screenHeight,
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
                              childAspectRatio: 2,
                            ),
                            itemCount: _keywords.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                  onLongPress: () {
                                    MYGO current = _keywords[index];
                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.all(16),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "詳細資訊",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Divider(),
                                              Text("Text: ${current.text}"),
                                              SizedBox(height: 8),
                                              Text(
                                                  "Episode: ${current.episode}"),
                                              SizedBox(height: 8),
                                              Text(
                                                  "Frame Start: ${current.frameStart}"),
                                              SizedBox(height: 8),
                                              Text(
                                                  "Frame End: ${current.frameEnd}"),
                                              SizedBox(height: 8),
                                              Text(
                                                  "Segment ID: ${current.segmentID}"),
                                              SizedBox(height: 16),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  TextButton(
                                                    onPressed: () async {
                                                      await downloadImage(
                                                          context,
                                                          _keywords[index]
                                                              .ImgURL());
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      "Copy Image",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Clipboard.setData(
                                                          ClipboardData(
                                                        text: current.ImgURL(),
                                                      ));
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  'Image URL copied to clipboard!')));
                                                    },
                                                    child: Text(
                                                      "Copy Image URL",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      "Cancel",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.red),
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    margin: EdgeInsets.all(3.0),
                                    color: Colors.white,
                                    child: Column(
                                      children: [
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
                                        Padding(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 8),
                                          child: Text(
                                            _keywords[index].text,
                                            style:
                                                TextStyle(color: Colors.black),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ));
                            },
                          ),
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
