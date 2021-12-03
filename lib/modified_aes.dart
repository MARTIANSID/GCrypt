import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';
import 'googleDrive.dart';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_rc4/simple_rc4.dart';

class Modified_aes {
  Future<String> modified_Encryption(
      String data, String secretKey, String path) async {
    var crypt = AesCrypt(secretKey);
    try {
      //aes
      await crypt.encryptTextToFile(data, path);
      Uint8List dec = await crypt.decryptDataFromFile(path);
      String s = String.fromCharCodes(dec);
      RC4 rc4 = new RC4(secretKey);
      //rc4
      var bytes = rc4.encodeBytes(utf8.encode(s));
      return String.fromCharCodes(bytes);
    } catch (e) {
      print("Encryption failed!");
    }
  }

  Future<String> modified_Decryption(String s, String path, File saveFile,
      String secretKey, List<int> dataStore) async {
    print("Task Done");
    var crypt = AesCrypt(secretKey);
    RC4 rc4 = new RC4(secretKey);
    //rc4
    var bytes = rc4.decodeBytes(dataStore);
    //aes
    Uint8List dec = await crypt.decryptDataFromFile(bytes);
    return String.fromCharCodes(dec);;
  }
}
