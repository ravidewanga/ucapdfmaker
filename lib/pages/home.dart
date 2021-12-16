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
  String cameraStatusMsg = '';
  String camPermissionMsg = '';

  //------**********--------------
  bool netConnection = false;
  int cameraStatus;
  int camPermission;
  bool allChecked = false;
  List installedAppList;
  bool loader = true;

  askPermission() async{
    bool camGranted = await Permission.camera.isGranted;
    bool camRationale = await Permission.camera.shouldShowRequestRationale;

    if(camGranted == true){
      //-------permission given----------
    }else if(camGranted == false && camRationale == true){
      await Permission.camera.request();
    }else if(camGranted == false && camRationale == true){
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

      if (cameraStatus != camCheck[1]) {
        cameraStatusMsg = camCheck[0];
        cameraStatus = camCheck[1];
      }

      if(camPermission != checkCamPer){
        if(checkCamPer == 2){
          camPermissionMsg = 'You have click never ask to permission.';
        }else{
          camPermissionMsg = '';
        }
        camPermission = checkCamPer;
      }

      if (allChecked != myAllCheck) {
        allChecked = myAllCheck;
      }
      loader = false;
    });
  }

  nextButton(){
    homeTimer?.cancel();
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
                leading: Image.asset('images/permission_check.png',height: 30,width: 30,),
                title: Text('Permission Check'),
                subtitle: camPermission != 1 ?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Permission to access the camera is missing.'),
                    InkWell(
                      onTap: askPermission,
                      child: Text('Give Permission',style: TextStyle(color: Colors.blue),),
                    ),
                  ],
                ):Container(),
                trailing: camPermission == 1
                    ?  Icon(Icons.check_circle,color: Colors.green,size: 25)
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
            content:Text('A new version of this application is available now, Please update.'),
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