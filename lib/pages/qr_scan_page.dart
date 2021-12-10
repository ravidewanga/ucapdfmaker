import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_appavailability/flutter_appavailability.dart';
import 'package:qr_code_tools/qr_code_tools.dart';
import 'package:rxdart/rxdart.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ucanassess_api.dart' as api;
import '../services/enc_dec.dart';
import '../services/global.dart' as global;
import '../widgets/my_widgets.dart';

class QRScanPage extends StatefulWidget {
  final ChromeSafariBrowser browser = new MyChromeSafariBrowser();
  final String referrerPage;
  QRScanPage({Key key,this.referrerPage}) : super(key: key);

  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {

  final picker = ImagePicker();
  Timer timer;
  Timer checkListTimer;

  static const platform = const MethodChannel('com.ucanapply.ravi/flutter_ravi');
  final MethodChannel _channel = MethodChannel('com.mews.kiosk_mode/kiosk_mode');

  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver('#ff6666', 'Cancel', true, ScanMode.BARCODE).listen((barcode) => print(barcode));
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    var result = await platform.invokeMethod('isInLockTaskMode');
    if (result == 0) { //--------check kiosk/pinning mode---------------
      Fluttertoast.showToast(
          msg: "Swipe right to LOCK your device to proceed forward.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.QR);
      redirectToExam(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
      //EasyLoading.dismiss();
      Fluttertoast.showToast(
          msg: "Something went wrong, Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    if (!mounted) return;
  }

  void getPhotoByGallery() {
    Stream.fromFuture(picker.getImage(source: ImageSource.gallery)).flatMap((file) {
      return Stream.fromFuture(QrCodeToolsPlugin.decodeFrom(file.path));
    }).listen((data) {
      redirectToExam(data);
    }).onError((error, stackTrace) {
      print('${error.toString()}');
      //EasyLoading.dismiss();
      Fluttertoast.showToast(
          msg: "Something went wrong, Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  @override
  void initState() {
    if(widget.referrerPage == 'take_exam'){
      checkListTimer = Timer.periodic(Duration(seconds: 2), (Timer t) => checkInstalledApp());
    }
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    checkListTimer?.cancel();
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
              title: Image.asset(
                'images/header_logo.png',
                fit: BoxFit.contain,
                height: 45,
              ),
              leading: global.secureMode
                  ? null
                  : GestureDetector(
                      onTap: () {
                        print('call');
                        timer?.cancel();
                        Navigator.pushReplacementNamed(context, "/options_page");
                      },
                      child: Icon(
                        Icons.arrow_back, // add custom icons also
                      ),
                    ),
            ),
          ),
          preferredSize: Size.fromHeight(kToolbarHeight),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  'You are now almost ready for launching your test. Swipe right to LOCK your device to proceed forward. Please note that once the device is locked you will be able to only exit from this examination application to unlock your device. Alternately if there is any issue in your device you can also reboot the device to unlock it.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  'So are you ready to start ?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.only(left: 50, right: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'No',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Transform.scale(
                      scale: 3,
                      child: Switch(
                        onChanged: secureModeToggle,
                        value: global.secureMode,
                        activeColor: Colors.white,
                        activeTrackColor: Colors.green,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.red,
                      ),
                    ),
                    Text(
                      'Yes',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              global.secureMode
                  ? Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Great! Now click on the button below to Scan the QR Code given in your E-Admit Card OR Examination launch page to Launch your examination.',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.justify,
                          ),
                        ),

                        SizedBox(height: 20),
                        buttonWidget(context,'Scan QR',scanQR,40.0,20.0),
                        SizedBox(height: 10),
                        Text('OR',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                        SizedBox(height: 10),
                        buttonWidget(context,'Choose QR from gallery',getPhotoByGallery,40.0,20.0),
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  redirectToExam(barcodeScanRes) async {
    var decodeURL = decryp(barcodeScanRes);
    if (checkUrl(decodeURL)) {
      //EasyLoading.show(status: 'loading...');
      if (await canLaunch(decodeURL)) {
        setState(() {
          global.examURL = decodeURL;
        });
        await widget.browser.open(
          url: Uri.parse(decodeURL.toString()),
          options: ChromeSafariBrowserClassOptions(
            android: AndroidChromeCustomTabsOptions(
              packageName: "com.android.chrome",
              addDefaultShareMenuItem: false,
              enableUrlBarHiding: false,
              toolbarBackgroundColor: global.primaryColor,
              showTitle: true,
            ),
            ios: IOSSafariOptions(barCollapsingEnabled: true),
          ),
        );
        // -------------- if remove the kiosk mode then clock chrome tab----------
        //timer?.cancel();
        global.timer2 = Timer.periodic(
            Duration(seconds: 2), (Timer t) => checkPinningMode());
      }
    } else {
      Fluttertoast.showToast(
          msg: "The scanned QR Code is not valid for any examination.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    //EasyLoading.dismiss();
  }

  checkSecureMode() async {
    print('check secure mode loop');
    bool res = false;
    var result = await platform.invokeMethod('isInLockTaskMode');
    if (result != 0) {
      res = true;
    }
    if (res != global.secureMode) {
      setState(() {
        global.secureMode = res;
      });
      if(res == false){
         timer?.cancel();
      }
    }
  }

  void secureModeToggle(bool value) {
    if (global.secureMode == false) {
      _channel.invokeMethod('startKioskMode');
      timer?.cancel();
      timer = Timer.periodic(Duration(seconds: 1), (Timer t) => checkSecureMode());
    } else {
      _channel.invokeMethod('stopKioskMode');
      setState(() {
        global.secureMode = false;
      });
      timer.cancel();
    }
  }

  bool checkUrl(String urlSource) {
    final uri = Uri.parse(urlSource);
    Uri.decodeFull(urlSource);
    final domain = uri.host;
    var domainArray = domain.split('.');
    var checkDomain = domainArray.contains('ucanapply');

    var getKey = Uri.dataFromString(urlSource);
    Map<String, String> params = getKey.queryParameters;
    var key = params['key'];
    if (checkDomain == true && key == 'ucaexam') {
      return true;
    }
    return false;
  }

  checkPinningMode() async {
    print('checking pinning mode timer');
    var result = await platform.invokeMethod('isInLockTaskMode');
    var browserStatus = widget.browser.isOpened();
    if (result == 0 && browserStatus == true) {
      setState(() {
        global.secureMode = false;
      });
      await widget.browser.close();
      global.timer2?.cancel();
      Fluttertoast.showToast(
          msg: "You cannot take any examination unless you are in LOCKED Mode.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  checkInstalledApp() async {
    List installedAppList = [];
    List<Map<String, String>> _installedApps = await AppAvailability.getInstalledApps();
    for (var data in _installedApps) {
      if (global.appList.contains(data['package_name'])) {
        installedAppList.add(data);
      }
    }
    if (installedAppList.length > 0) {
      checkListTimer?.cancel();
      Navigator.pushReplacementNamed(context, "/prohibited_app_list");
    }
  }

  Future<bool> _onWillPop() {
    if (global.secureMode == false) {
      timer?.cancel();
      Navigator.pushReplacementNamed(context, "/options_page");
    }
    return Future.value(true);
  }

}

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onCompletedInitialLoad() {
    print("ChromeSafari browser initial load completed");
  }

  @override
  void onClosed() async{
    global.timer2?.cancel();
    await api.stopExam(global.examURL);
    print("ChromeSafari browser closed");
  }
}
