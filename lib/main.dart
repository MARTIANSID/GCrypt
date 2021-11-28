import "dart:io";
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutterdrive/googleDrive.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:aes_crypt/aes_crypt.dart';
import 'package:path_provider/path_provider.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import 'content_show.dart';

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

  Future<void> _handleRefresh() async {
    //await Future.delayed(Duration(milliseconds: 1000));
    setState(() {});
  }

  void getSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Container(
              height: MediaQuery.of(context).size.height * 0.17,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.15,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      // gradient: LinearGradient(
                      //     tileMode: TileMode.mirror,
                      //     begin: Alignment.topCenter,
                      //     end: Alignment.bottomCenter,
                      //     colors: [
                      //       Colors.black,
                      //       Color.fromRGBO(11, 0, 48, 1)
                      //     ]),
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      //color: Color.fromRGBO(0, 0, 0, 0.8)
                    ),
                    //color: Color.fromRGBO(0, 0, 0, 0.8),
                    alignment: Alignment.center,
                    child: Center(
                      child: Container(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  'Decrypting File',
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.03),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                width: 200,
                                child: LinearProgressIndicator(
                                    color: Colors.blue,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white)),
                              )

                              // Text(
                              //   'Logged In',
                              //   style: TextStyle(
                              //       fontSize:
                              //           MediaQuery.of(context).size.height *
                              //               0.03),
                              // ),
                              // SizedBox(
                              //   width: 20,
                              // ),
                              // Icon(
                              //   Icons.done_all,
                              //   color: Colors.white,
                              //   size: 40,
                              // )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ),
        //content: const Text('Account Created'),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.6),
        //width: double.infinity,
        // padding: const EdgeInsets.symmetric(
        //   horizontal: 8.0,
        // ),
        behavior: SnackBarBehavior.fixed,
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(10.0),
        // ),
        // action: SnackBarAction(
        //   label: 'Action',
        //   onPressed: () {},
        // ),
      ),
    );
  }

  void getLoadingBar(name, id, context) async {
    getSnackBar();
    String p = await drive.downloadGoogleDriveFile(name, id, context);
  }

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
          String path = file.path;
          String fileName = path.substring(path.lastIndexOf('/'));
          print("Choot Name -> $fileName");

          String data = await File(file.path).readAsString();
          var crypt = AesCrypt("SexyBitch@99");

          // crypt.encryptTextToFile(srcString, destFilePath)(srcFilePath)
          String encrypted = await crypt.encryptTextToFile(
              data, '${tempDir.path}/$fileName.aes');
          //String encrypted = await crypt.encryptTextToFile(data, '${tempDir.path}/rm.aes');
          File encFile = File(encrypted);

          Uint8List dec = await crypt.decryptDataFromFile(encFile.path);

          String s = String.fromCharCodes(dec);
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
        child: LiquidPullToRefresh(
          onRefresh: _handleRefresh,
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
                          return Container(
                            padding: const EdgeInsets.only(
                                top: 20, left: 20, right: 20),
                            child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 2.5 / 3,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 5,
                                ),
                                itemBuilder: (BuildContext ctx, index) {
                                  return Container(
                                      //padding: EdgeInsets.all(16),
                                      margin: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.blue.withOpacity(0.3),
                                          style: BorderStyle.solid,
                                          width: 2,
                                        ),
                                      ),
                                      child: GestureDetector(
                                        onTap: () async {
                                          getLoadingBar(
                                              snapchat.data.files[index].name,
                                              snapchat.data.files[index].id,
                                              context);
                                          // String p = await drive
                                          //     .downloadGoogleDriveFile(
                                          //         snapchat
                                          //             .data.files[index].name,
                                          //         snapchat.data.files[index].id,
                                          //         context);
                                          //print("$p + ggg");
                                          // File file = File(p);
                                          // //print(file.exists());
                                          // String data = await File(file.path)
                                          //     .readAsString();
                                          // print("Taking to next screen");
                                          // print(data);

                                          //take to second page to show the content

                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) =>
                                          //             ContentShow(data)));
                                        },
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 10.0,
                                                right: 10.0,
                                                top: 60,
                                                bottom: 45,
                                              ),
                                              child: Container(
                                                height: 50,
                                                child: Center(
                                                  child: Image.asset(
                                                    'assets/file.png',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Container(
                                                  height: 20,
                                                  child: Image.asset(
                                                    'assets/file.png',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Container(
                                                  //padding: EdgeInsets.all(16),
                                                  child: Text(
                                                      snapchat.data.files[index]
                                                          .name,
                                                      style: TextStyle(
                                                          fontSize: 13)),
                                                ),
                                              ],
                                            ),
                                            // Row(
                                            //   children: [
                                            //     Container(
                                            //       child: Text(
                                            //         '${snapchat.data.files[index].}',
                                            //         style:
                                            //             TextStyle(fontSize: 10),
                                            //       ),
                                            //     )
                                            //   ],
                                            // )
                                          ],
                                        ),
                                      ));
                                },
                                itemCount: snapchat.data.files.length),
                          );
                        },
                      ),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
                future: drive.listGoogleDriveFiles(),
              ),
              // TextButton(
              //   child: Text('refresh'),
              //   onPressed: () {
              //     setState(() {
              //       // future: drive.listGoogleDriveFiles();
              //     });
              //   },
              // ),
              // TextButton(
              //     onPressed: () {
              //       setState(() {});
              //     },
              //     child: Text("Refresh"))
            ],
          ),
        ),
      ),
    );
  }
}
