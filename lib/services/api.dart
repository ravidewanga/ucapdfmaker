import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_share/flutter_share.dart';

Future<void> shareFile(title,text,file) async {
  await FlutterShare.shareFile(
    title: title,
    text: text,
    filePath: file.toString(),
  );
}

Future<void> gotToUpdate() async {
  var url = 'https://play.google.com/store/apps/details?id=com.ucanapply.ucanassess';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Future<void> deleteCacheDir() async {
  final cacheDir = await getTemporaryDirectory();
  print('cacheDir $cacheDir');
  if (cacheDir.existsSync()) {
    cacheDir.deleteSync(recursive: true);
  }
}

Future<void> removeCompressedFile() async {
  List cacheDir = await getExternalCacheDirectories();
  for(var ff in cacheDir){
    if (ff.existsSync()) {
      ff.deleteSync(recursive: true);
    }
  }
}

Future <bool> checkFileName(filename) async{
  final dirPath = (await getExternalStorageDirectory())?.path;
  Directory dir = Directory(dirPath);
  final checkPathExistence = await Directory(dirPath).exists();
  if(checkPathExistence){
    List allContents = dir.listSync(recursive: true);
    bool flag = false;
    for(var ff in allContents){
      var name = path.basename(ff.path);
      if(name == filename+'.pdf'){
        flag = true;
      }
    }
    return flag;
  }else{
    return false;
  }
}

Future<int> getVersionInfo() async{
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  var ver = androidInfo.version.release;
  var splitVer = ver.split('.');
  return int.parse(splitVer[0].toString());
}