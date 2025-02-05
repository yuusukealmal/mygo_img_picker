import 'package:flutter/material.dart';
import 'package:mygo_img_picker/api/updateCheck.dart';
import 'package:mygo_img_picker/pages/MyHomePage.dart';
import 'package:mygo_img_picker/pages/UpdatePage.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mygo_img_picker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: isLatest(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            return Scaffold(
                body: Center(child: Text('Error: ${snapshot.error}')));
          } else {
            debugPrint(snapshot.data);
            if (snapshot.data!.isEmpty || snapshot.data == null) {
              return MyHomePage(title: 'Mygo Image Picker');
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: Text("Update Available"),
                      content: Text(
                          "A new version of Mygo Image Picker is available. Please update to the latest version."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel",
                              style: TextStyle(color: Colors.red)),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          UpdatePage(hash: snapshot.data!)));
                            },
                            child: Text("Update")),
                      ],
                    );
                  },
                );
              });
              return MyHomePage(title: 'Mygo Image Picker');
            }
          }
        },
      ),
    );
  }
}
