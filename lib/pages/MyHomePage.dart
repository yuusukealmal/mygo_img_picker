import 'package:flutter/material.dart';
import 'package:mygo_img_picker/api/imgDownload.dart';
import 'package:mygo_img_picker/api/searchString.dart';
import 'package:mygo_img_picker/class/content.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Movable Floating Ball'),
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
                              return Card(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
