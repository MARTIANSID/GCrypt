import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutterdrive/googleDrive.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:aes_crypt/aes_crypt.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Drive',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final drive = GoogleDrive();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var file = await FilePicker.getFile();
          var crypt = AesCrypt("SexyBitch@99");
          var p = crypt.encryptFileSync(file.path, '/storage/emulated/0/Download/choot.aes');
          print("check file path $p");
          // await drive.upload(File(p));
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text("Flutter Drive Demo"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder(
              builder: (BuildContext ctx, AsyncSnapshot<Stream<ga.FileList>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Expanded(
                    child: StreamBuilder(
                      stream: snapshot.data,
                      builder: (BuildContext ctx, AsyncSnapshot<ga.FileList> snapchat) {
                        if (!snapchat.hasData) return CircularProgressIndicator();
                        return ListView.builder(
                            itemBuilder: (BuildContext ctx, index) {
                              return Text(snapchat.data.files[index].name);
                            },
                            itemCount: snapchat.data.files.length);
                      },
                    ),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
              future: drive.listGoogleDriveFiles(),
            ),
            TextButton(
                onPressed: () {
                  setState(() {});
                },
                child: Text("Refresh"))
          ],
        ),
      ),
    );
  }
}
