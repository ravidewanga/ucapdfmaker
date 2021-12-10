import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_appavailability/flutter_appavailability.dart';
import '../pages/qr_scan_page.dart';
import '../services/global.dart' as global;

class ProhibitedAppList extends StatefulWidget {
  @override
  _ProhibitedAppListState createState() => _ProhibitedAppListState();
}

class _ProhibitedAppListState extends State<ProhibitedAppList> {
  Timer prohibitedAppListTimer;
  List installedApp = [];
  bool loader = true;

  Future<void>checkInstalledApp() async {
    List installedAppList = [];
    List<Map<String, String>> _installedApps = await AppAvailability.getInstalledApps();
    for (var data in _installedApps) {
      if (global.appList.contains(data['package_name'])) {
        installedAppList.add(data);
      }
    }
    if(installedAppList.length > 0){
      setState(() {
        installedApp = installedAppList;
        loader = false;
      });
    }else{
      prohibitedAppListTimer?.cancel();
      Navigator.push(context,MaterialPageRoute(builder: (context) =>QRScanPage(referrerPage:'take_exam')));
      //Navigator.pushReplacementNamed(context, "/qr_scan_page");
    }
  }
  Future<bool> _onWillPop(){
    prohibitedAppListTimer?.cancel();
    Navigator.pushReplacementNamed(context, "/options_page");
    return Future.value(true);
  }

  @override
  void initState() {
    prohibitedAppListTimer = Timer.periodic(Duration(seconds: 2), (Timer t) => checkInstalledApp());
    super.initState();
  }

  @override
  void dispose() {
    prohibitedAppListTimer?.cancel();
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
              leading:GestureDetector(
                onTap: () {
                  prohibitedAppListTimer?.cancel();
                  Navigator.pushReplacementNamed(context, "/options_page");
                },
                child: Icon(
                  Icons.arrow_back,  // add custom icons also
                ),
              ),
              actions: [
                IconButton(
                  onPressed: checkInstalledApp,
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          preferredSize: Size.fromHeight(kToolbarHeight),
        ),
        body: RefreshIndicator(
          child: loader ? Center(
            child: CircularProgressIndicator(),
          ): Column(
            children: [
              Container(
                color: Color(0xFFF19F34),
                padding: EdgeInsets.all(10),
                child: Center(
                  child: Text("PROHIBITED APPLICATIONS DETECTED",style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              Container(
                padding: EdgeInsets.only(top: 10,left: 5,right: 5,bottom: 10),
                child: RichText(
                  text: TextSpan(
                    text: 'The following applications on your phone are prohibited for this examination. Please uninstall ALL of these applications to proceed forward.',
                    style: TextStyle(fontSize: 14,color: Colors.black,fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: installedApp.length,
                  itemBuilder: (context, index) {
                    return Container(
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              installedApp[index]["app_name"],
                              style: TextStyle(fontSize: 18),
                            ),
                            trailing: Icon(Icons.cancel,color: Colors.red,size: 25),
                          ),

                          index < installedApp.length - 1  ?
                          Container(
                            color: Colors.grey[300],
                            height: 1.5,
                          ) : Container(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          onRefresh:checkInstalledApp,
        ),
      ),
    );
  }
}
