// import 'dart:html';
import 'dart:typed_data';
import 'dart:io';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:flutter/material.dart';
import 'package:flutterdrive/content_show.dart';
import 'package:flutterdrive/secureStorage.dart';
// import 'package:googleapis/drive/v2.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

const _clientId =
    "413371350735-k4ug5ill9npdgh1lufq2nk6he2a37me5.apps.googleusercontent.com";
const _clientSecret = "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";
const _scopes = ["https://www.googleapis.com/auth/drive"];

class GoogleDrive {
  final storage = SecureStorage();
  //Get Authenticated Http Client
  Future<http.Client> getHttpClient() async {
    //Get Credentials
    var credentials = await storage.getCredentials();
    if (credentials == null) {
      //Needs user authentication
      var authClient = await clientViaUserConsent(
          ClientId(_clientId, _clientSecret), _scopes, (url) {
        //Open Url in Browser
        launch(url);
      });
      //Save Credentials
      await storage.saveCredentials(authClient.credentials.accessToken,
          authClient.credentials.refreshToken);
      return authClient;
    } else {
      print(credentials["expiry"]);
      //Already authenticated
      return authenticatedClient(
          http.Client(),
          AccessCredentials(
              AccessToken(credentials["type"], credentials["data"],
                  DateTime.tryParse(credentials["expiry"])),
              credentials["refreshToken"],
              _scopes));
    }
  }

  //Upload File
  Future upload(File file) async {
    var client = await getHttpClient();
    var drive = ga.DriveApi(client);
    print("Uploading file");
    var response = await drive.files.create(
        ga.File()..name = p.basename(file.absolute.path),
        uploadMedia: ga.Media(file.openRead(), file.lengthSync()));

    print("Result ${response.toJson()}");
  }

  Future<Stream<ga.FileList>> listGoogleDriveFiles() async {
    var client = await getHttpClient();
    var drive = ga.DriveApi(client);
    return drive.files.list(spaces: 'drive').asStream();
    // drive.files.list(spaces: 'drive').then((value) {
    //   for (int i = 0; i < value.files.length; i++) {
    //     print(value.files[i].name);
    //   }
    //   return value.files;
    // });
  }

  Future<String> downloadGoogleDriveFile(
      String fName, String gdID, BuildContext context, String givingKey) async {
    var client = await getHttpClient();
    var drive = ga.DriveApi(client);
    ga.Media file = await drive.files
        .get(gdID, downloadOptions: ga.DownloadOptions.FullMedia);
    print(file.stream);
    final directory = await getExternalStorageDirectory();
    print(directory.path);
    final saveFile = File(
        '${directory.path}/${new DateTime.now().millisecondsSinceEpoch}$fName');
    List<int> dataStore = [];
    file.stream.listen((data) {
      print("DataReceived: ${data.length}");
      dataStore.insertAll(dataStore.length, data);
    }, onDone: () async {
      print("Task Done");
      var crypt = AesCrypt("$givingKey");
      File f = await saveFile.writeAsBytes(dataStore);
      Uint8List g = await crypt.decryptDataFromFile(saveFile.path);
      print(new String.fromCharCodes(g));
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContentShow(String.fromCharCodes(g), fName)),
      );
      return saveFile.path;
    }, onError: (error) {
      print("Some Error");
    });
  }
}
