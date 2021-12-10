import 'package:camera/camera.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appavailability/flutter_appavailability.dart';
import 'package:permission_handler/permission_handler.dart';

const MethodChannel _sharedChannel = const MethodChannel('com.pichillilorenzo/flutter_chromesafaribrowser');

Future<int> getBatteryLevel() async {
  const platform = const MethodChannel('com.ucanapply.ravi/flutter_ravi');
  int batteryLevel;
  try {
    final int result = await platform.invokeMethod('getBatteryLevel');
    batteryLevel = result;
  } on PlatformException catch (e) {
    print(e);
    batteryLevel = 0;
  }
  return batteryLevel;
}

Future<bool> checkNetConnection() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult != ConnectivityResult.none) {
    return true;
  } else {
    return false;
  }
}

Future<bool> checkChrome() async {
  bool chromeStatus = false;
  try {
    Map chromeList = await AppAvailability.checkAvailability("com.android.chrome");
    if (chromeList['version_name'] != null) {
      var verSplit = chromeList['version_name'].split('.');
      if(int.parse(verSplit[0]) >= 72){
        chromeStatus = true;
      }
    }
  } catch (e) {
    chromeStatus = false;
  }
  return chromeStatus;
  // print(chromeList['app_name']);
  // print(chromeList['version_name']);
  // print(chromeList['package_name']);
}

Future<bool> isAvailableChromeTab() async {
Map<String, dynamic> args = <String, dynamic>{};
return await _sharedChannel.invokeMethod("isAvailable", args);
}

Future <int> checkCameraPermission() async{
  bool isGranted = await Permission.camera.isGranted;
  //bool isDenied = await Permission.camera.isDenied;
  bool camRationale = await Permission.camera.shouldShowRequestRationale; // false means not showing again

  if(isGranted == true){
    return 1; // granted
  }else if(camRationale == false){
    //openAppSettings();
    return 2; // never ask again
  }else{
    return 3; // denied
  }
}

Future <int> checkMicPermission() async{
  bool isGranted = await Permission.microphone.isGranted;
  //bool isDenied = await Permission.microphone.isDenied;
  bool micRationale = await Permission.microphone.shouldShowRequestRationale; // false means not showing again

  if(isGranted == true){
    return 1; // granted
  }else if(micRationale == false){
    return 2; // never ask again
  }else{
    return 3; // denied
  }
}

Future<List> cameraChecking() async {
  int cameraStatus  = 1;
  String camMsg = '';
  final cameras = await availableCameras(); //get list of available cameras
  final backCam = cameras[0]; //get the back camera and do what you want
  final frontCam = cameras[1]; //get the front camera and do what you want

  if(frontCam.lensDirection != CameraLensDirection.front){
    camMsg = 'This test requires your device to have a Front facing camera. Please change your device.';
    cameraStatus = 0;
  }

  if(backCam.lensDirection != CameraLensDirection.back){
    camMsg = 'Your device does not seem to have a Back facing camera. Some tests require upload of clicked images. This will not be feasible on your device. Please take care.';
    cameraStatus = 2;
  }

  List rData = [camMsg,cameraStatus];
  return rData;
}

Future<bool> getTimeZone() async {
  bool timeZone = false;
  DateTime dateTime = DateTime.now();
  if (dateTime.timeZoneName == 'IST') {
    timeZone = true;
  } else {
    timeZone = false;
  }
  return timeZone;
}