import "dart:io";
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutterdrive/googleDrive.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:aes_crypt/aes_crypt.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Drive',
      theme: ThemeData(
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
          Directory tempDir = await getApplicationSupportDirectory();
          print("Dir Check -> ${tempDir.path}");
          var file = await FilePicker.getFile();
          String data = await File(file.path).readAsString();
          var crypt = AesCrypt("SexyBitch@99");

          // crypt.encryptTextToFile(srcString, destFilePath)(srcFilePath)
          String encrypted = await crypt.encryptTextToFile(
              data, '${tempDir.path}/sample_67.aes');
          File encFile = File(encrypted);

          Uint8List dec = await crypt.decryptDataFromFile(encFile.path);

          String s = new String.fromCharCodes(dec);
          print("choot dec text $s");

          // String encText = await encFile.readAsString();
          // print("data -> $encText");
          print("check file path $encrypted");
          await drive.upload(File(encFile.path));
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
              builder: (BuildContext ctx,
                  AsyncSnapshot<Stream<ga.FileList>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Expanded(
                    child: StreamBuilder(
                      stream: snapshot.data,
                      builder: (BuildContext ctx,
                          AsyncSnapshot<ga.FileList> snapchat) {
                        if (!snapchat.hasData)
                          return Center(child: CircularProgressIndicator());
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
