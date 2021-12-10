import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:package_info/package_info.dart';
import 'package:http/http.dart' as http;
import '../services/global.dart' as global;
import '../services/enc_dec.dart';
import '../widgets/my_widgets.dart';
import '../services/mandatory_checklist.dart' as check;
import '../services/ucanassess_api.dart' as api;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Timer homeTimer;
  int batteryPer = 0;

  //---------*********-----------------
  String netConnectionMsg = 'This test requires dedicated un-interrupted internet availability on the phone. Please ensure the same';
  String chromeStatusMsg = 'This test requires a Chrome Browser V72 or above. Please install/update the same.';
  String chromeTabStatusMsg = 'This test requires a device with latest Android OS / Firmware. Please change your device.';
  String cameraStatusMsg = '';
  String timeZoneStatusMsg = 'This test requires Time Zone to be set to "India Standard Time" also time should be set to synchronize from the network. Please ensure the same.';
  String camPermissionMsg = '';
  String micPermissionMsg = '';

  //------**********--------------
  bool netConnection = false;
  bool chromeStatus = false;
  bool chromeTabStatus = false;
  int cameraStatus;
  int camPermission;
  int micPermission;
  bool timeZoneStatus = false;
  bool allChecked = false;
  List installedAppList;
  bool loader = true;

  askPermission() async{
    bool camGranted = await Permission.camera.isGranted;
    //bool camDenied = await Permission.camera.isDenied;
    bool camRationale = await Permission.camera.shouldShowRequestRationale;

    bool micGranted = await Permission.microphone.isGranted;
    //bool micDenied = await Permission.microphone.isDenied;
    bool micRationale = await Permission.microphone.shouldShowRequestRationale;

    print('micGranted $micGranted');
    print('micRationale $micRationale');

    if(camGranted == true && micGranted == true){
      //-------permission given----------
    }else if((camGranted == false && camRationale == true) && (micGranted == false && micRationale == true)){
      await Permission.camera.request();
      await Permission.microphone.request();
    }else if(camGranted == true && (micGranted == false && micRationale == true)){
      await Permission.microphone.request();
    }else if((camGranted == false && camRationale == true) && micGranted == true){
      await Permission.camera.request();
    }else{
      openAppSettings();
    }
  }

  versionCheck() async {
    var header = encryp('com.ucanapply.ucanassess');
    http.Response response = await http.get(
      Uri.parse(global.baseUrl),
      headers: {"Authorization": header},
    );
    Map data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      int newVersion = data['build_no'];
      bool updateRequired = data['updateRequired'];

      final PackageInfo info = await PackageInfo.fromPlatform();
      if (newVersion > int.parse(info.buildNumber)) {
        Future.delayed(Duration.zero, () {
          this.updateVersion(updateRequired);
        });
      }
      setState(() {
        global.versionCheck = false;
      });
    }
  }

  getALlCheck() async {
    int battery = await check.getBatteryLevel();
    bool internet = await check.checkNetConnection();
    bool chrome = await check.checkChrome();
    List camCheck = await check.cameraChecking();
    bool timeCheck = await check.getTimeZone();
    bool chromeTab = await check.isAvailableChromeTab();
    int checkCamPer = await check.checkCameraPermission();
    int checkMicPer = await check.checkMicPermission();

    bool myAllCheck = false;
    if (internet == true && camCheck[1] != 0 && timeCheck == true && checkCamPer == 1)
    {
      myAllCheck = true;
    }

    setState(() {
      if (batteryPer != battery) {
        batteryPer = battery;
      }
      if (netConnection != internet) {
        if (internet == false) {
          netConnectionMsg = 'This test requires dedicated un-interrupted internet availability on the phone. Please ensure the same.';
        } else {
          netConnectionMsg = '';
        }
        netConnection = internet;
      }

      // if (chromeStatus != chrome) {
      //   if (chrome == false) {
      //     chromeStatusMsg = 'This test requires a Chrome Browser V72 or above. Please install/update the same.';
      //   } else {
      //     chromeStatusMsg = '';
      //   }
      //   chromeStatus = chrome;
      // }

      // if (chromeTabStatus != chromeTab) {
      //   if (chromeTab == false) {
      //     chromeTabStatusMsg = 'This test requires a device with latest Android OS / Firmware. Please change your device.';
      //   } else {
      //     chromeTabStatusMsg = '';
      //   }
      //   chromeTabStatus = chromeTab;
      // }

      if (cameraStatus != camCheck[1]) {
        cameraStatusMsg = camCheck[0];
        cameraStatus = camCheck[1];
      }

      if (timeZoneStatus != timeCheck) {
        if (timeCheck == false) {
          timeZoneStatusMsg = 'This test requires Time Zone to be set to "India Standard Time" also time should be set to synchronize from the network. Please ensure the same.';
        } else {
          timeZoneStatusMsg = '';
        }
        timeZoneStatus = timeCheck;
      }

      if(camPermission != checkCamPer){
        if(checkCamPer == 2){
          camPermissionMsg = 'You have click never ask to permission.';
        }else{
          camPermissionMsg = '';
        }
        camPermission = checkCamPer;
      }

      if(micPermission != checkMicPer){
        if(checkMicPer == 2){
          camPermissionMsg = 'You have clicked never ask to permission.';
        }else{
          camPermissionMsg = '';
        }
        micPermission = checkMicPer;
      }

      if (allChecked != myAllCheck) {
        allChecked = myAllCheck;
      }
      loader = false;
    });
  }

  // nextButton(){
  //   homeTimer?.cancel();
  //   if(installedAppList.length > 0){
  //     Navigator.push(context,MaterialPageRoute(builder: (context) => ProhibitedAppList()),);
  //   }else{
  //     Navigator.pushReplacementNamed(context, "/qr_scan_page");
  //   }
  // }

  nextButton(){
    homeTimer?.cancel();
    //Navigator.pushNamed(context, "/options_page");
    Navigator.pushNamed(context, "/pdf_list");
  }

  @override
  void initState() {
    if(global.versionCheck){
      versionCheck();
    }
    homeTimer = Timer.periodic(Duration(seconds: 2), (Timer t) => getALlCheck());
    super.initState();
  }

  @override
  void dispose() {
    homeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: PreferredSize(
          child: Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: global.primaryColor,
                offset: Offset(0, 1.5),
                blurRadius: 1.0,
              )
            ]),
            child: AppBar(
              title: Image.asset('images/header_logo.png',fit: BoxFit.contain,height: 45,),
              leading: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset("images/logo_icon.png",),
              ),
              actions: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: ClipOval(
                    child: Material(
                      //color: Colors.white, // Button color
                      child: InkWell(
                        splashColor: Colors.green, // Splash color
                        onTap: () =>{
                          Navigator.push(context,MaterialPageRoute(builder: (context) => Home()))
                        },
                        child: SizedBox(
                          width: 37,
                          height: 37,
                          child: Icon(Icons.refresh),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          preferredSize: Size.fromHeight(kToolbarHeight),
        ),
        body: loader
            ? Center(
          child: CircularProgressIndicator(),
        )
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Color(0xFFF19F34),
                padding: EdgeInsets.all(10),
                child: Center(
                  child: Text("MANDATORY SYSTEM REQUIREMENT CHECK",style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10,left: 5,right: 5,bottom: 10),
                child: RichText(
                  text: TextSpan(
                    text: 'The following are mandatory system requirements for taking the test. All requirements should have a ',
                    style: TextStyle(fontSize: 14,color: Colors.black,fontWeight: FontWeight.bold),
                    children:[
                      WidgetSpan(
                        child: Icon(Icons.check_circle,size: 14,color: Colors.green),
                      ),
                      TextSpan(text: ' mark against them to proceed forward. To resolve any issues please refer to directions given:'),
                    ],
                  ),
                ),
              ),

              ListTile(
                leading: Image.asset('images/battery.png',height: 30,width: 30,),
                title: Text('Battery'),
                subtitle: batteryPer < 60 ? Text('Ideally your phone should be having a minimum charge of 60% to avoid your device from getting switched off in the middle of the test. Please take care.') : null,
                trailing:Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(batteryPer.toString() + '%',
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                    ),
                    batteryPer < 60 ? Icon(Icons.warning,color: Color(0xFFf0ad4e),size: 25):
                    Icon(Icons.check_circle,color: Colors.green,size: 25)
                  ],
                ),
              ),
              divider(context),

              ListTile(
                leading: Image.asset('images/internet.png',height: 30,width: 30,),
                title: Text('Internet'),
                subtitle: netConnectionMsg != ""
                    ? Text(netConnectionMsg)
                    : null,
                trailing: netConnection
                    ? Icon(Icons.check_circle,color: Colors.green,size: 25)
                    : Icon(Icons.cancel,color: Colors.red,size: 25),
              ),

              divider(context),


              ListTile(
                leading: Image.asset('images/camera.png',height: 30,width: 30,),
                title: Text('Camera Check'),
                subtitle: cameraStatusMsg != ""
                    ? Text(cameraStatusMsg)
                    : null,
                trailing: cameraStatus == 1
                    ? Icon(Icons.check_circle,color: Colors.green,size: 25)
                    : cameraStatus == 2 ? Icon(Icons.warning,color: Color(0xFFf0ad4e),size: 25)
                    : Icon(Icons.cancel,color: Colors.red,size: 25),
              ),

              divider(context),

              ListTile(
                leading: Image.asset('images/time.png',height: 30,width: 30,),
                title: Text('Time Zone'),
                subtitle: timeZoneStatusMsg != ""
                    ? Text(timeZoneStatusMsg)
                    : null,
                trailing: timeZoneStatus
                    ? Icon(Icons.check_circle,color: Colors.green,size: 25)
                    : Icon(Icons.cancel,color: Colors.red,size: 25),
              ),

              divider(context),

              ListTile(
                leading: Image.asset('images/permission_check.png',height: 30,width: 30,),
                title: Text('Permission Check'),
                subtitle: camPermission != 1 || micPermission != 1 ?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Permission to access the camera & microphone is missing.'),
                    InkWell(
                      onTap: askPermission,
                      child: Text('Give Permission',style: TextStyle(color: Colors.blue),),
                    ),
                  ],
                ):Container(),
                trailing: camPermission == 1 && micPermission == 1
                    ?  Icon(Icons.check_circle,color: Colors.green,size: 25)
                    // : camPermission == 1 ? Icon(Icons.warning,color: Color(0xFFf0ad4e),size: 25)
                    : Icon(Icons.cancel,color: Colors.red,size: 25),
              ),

              SizedBox(height: 15),

              Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    buttonWidget(context,'Next',allChecked ? nextButton : null,40.0,15.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
      //barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: new Text(
          'Do you want to close this application?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => {Navigator.of(context).pop(false)},
            child: new Text(
              'No',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => exit(0),
            child: new Text(
              'Yes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<void> updateVersion(updateRequired) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            //title: Text('A new version of this application is available now, Please update before taking any examination.'),
            content:Text('A new version of this application is available now, Please update before taking any examination.'),
            actions: <Widget>[
              updateRequired
                  ? Container()
                  : TextButton(
                child: new Text(
                  'Cancel',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey),
                ),
                onPressed: () {
                  setState(() {
                    global.versionCheck = false;
                  });
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                onPressed: () => api.gotToUpdate(),
                child: new Text(
                  'Update Now',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}