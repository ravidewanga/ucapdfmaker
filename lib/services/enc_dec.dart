import 'package:encrypt/encrypt.dart';
final key = Key.fromUtf8('chsuwphxkeuqckyxtcehqevtxxtvfwsz'); //32 chars
final iv = IV.fromUtf8('boigdllvajnywxls'); //16 chars

//   Flutter encryption
String encryp(String text) {
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  final encrypted = encrypter.encrypt(text, iv: iv);
//   print('text : $text');
//   print('encrypted : ${encrypted.base64}');
  return encrypted.base64;
}

//Flutter decryption
String decryp(String text) {
  var newtext = text.split(' ');
  print('new array');
  print(newtext);
  var newText = newtext.join("+");
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  final decrypted = encrypter.decrypt(Encrypted.fromBase64(newText), iv: iv);
  print('text dec: '+ decrypted);
  return decrypted;
}