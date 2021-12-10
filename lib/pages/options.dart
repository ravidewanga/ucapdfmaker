import 'package:flutter/material.dart';
import 'package:flutter_appavailability/flutter_appavailability.dart';
import '../pages/qr_scan_page.dart';
import '../pages/prohibited_app_list.dart';
import '../services/global.dart' as global;

class Options extends StatefulWidget {
  @override
  _OptionsState createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  List installedAppList = [];
  checkInstalledApp() async {
    List list = [];
    List<Map<String, String>> _installedApps = await AppAvailability.getInstalledApps();
    for (var data in _installedApps) {
      if (global.appList.contains(data['package_name'])) {
        list.add(data);
      }
    }
    setState(() {
      installedAppList = list;
    });
  }

  takeExam(){
    if(installedAppList.length > 0){
      Navigator.push(context,MaterialPageRoute(builder: (context) => ProhibitedAppList()),);
    }else{
      Navigator.push(context,MaterialPageRoute(builder: (context) =>QRScanPage(referrerPage:'take_exam')));
      //Navigator.of(context).pushNamedAndRemoveUntil('/qr_scan_page', (Route<dynamic> route) => false);
    }
  }

  secondaryDevice(){
    Navigator.push(context,MaterialPageRoute(builder: (context) =>QRScanPage(referrerPage:'secondary_device')));
    //Navigator.of(context).pushNamedAndRemoveUntil('/qr_scan_page', (Route<dynamic> route) => false);
  }

  pdfUpload(){
    Navigator.of(context).pushNamed('/pdf_list');
  }

  Future<bool> onWillPop(){
    Navigator.of(context).pushNamed('/home');
    return Future.value(true);
  }

  @override
  void initState() {
    checkInstalledApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
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
              leading:GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, "/home");
                },
                child: Icon(
                  Icons.arrow_back,  // add custom icons also
                ),
              ),
            ),
          ),
          preferredSize: Size.fromHeight(kToolbarHeight),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                color: Color(0xFFF19F34),
                padding: EdgeInsets.all(10),
                child: Center(
                  child: Text("WHAT DO YOU WANT TO DO?",style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 10,),
              Container(
                padding: EdgeInsets.only(left: 10,right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints.tightFor(width: MediaQuery.of(context).size.width/2.2, height: 100),
                      child: ElevatedButton(
                        onPressed: takeExam,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: '',
                            style: DefaultTextStyle.of(context).style,
                            children: const <TextSpan>[
                              TextSpan(text: 'Take Exam\n', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18)),
                              TextSpan(text: '[Using this device]',style: TextStyle(color: Colors.white,fontSize: 12)),
                            ],
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: global.primaryColor,
                          primary: Colors.white,
                          //minimumSize: Size(88, 36),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          ),
                          //side: BorderSide(width: 1.5, color: Colors.white),
                        ),
                      ),
                    ),

                    ConstrainedBox(
                      constraints: BoxConstraints.tightFor(width: MediaQuery.of(context).size.width/2.2, height: 100),
                      child: ElevatedButton(
                        onPressed: pdfUpload,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: '',
                            style: DefaultTextStyle.of(context).style,
                            children: const <TextSpan>[
                              TextSpan(text: 'PDF Upload\n', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18)),
                              TextSpan(text: '[Upload file during test]',style: TextStyle(color: Colors.white,fontSize: 12)),
                            ],
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: global.primaryColor,
                          primary: Colors.white,
                          //minimumSize: Size(88, 36),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          ),
                          //side: BorderSide(width: 1.5, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              Container(
                padding: EdgeInsets.only(left: 10,right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints.tightFor(width: MediaQuery.of(context).size.width/2.2, height: 100),
                      child: ElevatedButton(
                        onPressed: secondaryDevice,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: '',
                            style: DefaultTextStyle.of(context).style,
                            children: const <TextSpan>[
                              TextSpan(text: 'Pair Device\n', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18)),
                              TextSpan(text: '[For 2 device proctoring]',style: TextStyle(color: Colors.white,fontSize: 12)),
                            ],
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: global.primaryColor,
                          primary: Colors.white,
                          //minimumSize: Size(88, 36),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          ),
                          //side: BorderSide(width: 1.5, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
