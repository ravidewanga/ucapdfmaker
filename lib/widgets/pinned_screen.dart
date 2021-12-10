import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../services/global.dart' as global;

class PinnedScreen extends StatefulWidget {
  @override
  _PinnedScreenState createState() => _PinnedScreenState();
}

class _PinnedScreenState extends State<PinnedScreen> {
  final MethodChannel _channel = MethodChannel('com.mews.kiosk_mode/kiosk_mode');
  static const platform = const MethodChannel('com.ucanapply.ravi/flutter_ravi');

  Timer timer;

  void secureModeToggle(bool value) {
    if (global.secureMode == false) {
      _channel.invokeMethod('startKioskMode');
      timer = Timer.periodic(Duration(seconds: 1), (Timer t) => checkSecureMode());
    } else {
      _channel.invokeMethod('stopKioskMode');
      timer.cancel();
      setState(() {
        global.secureMode = false;
      });
    }
  }

  checkSecureMode() async {
    bool res = false;
    var result = await platform.invokeMethod('isInLockTaskMode');
    if(result != 0){
      res = true;
      timer?.cancel();
      //Navigator.push(context, MaterialPageRoute(builder: (context) => QRScanPage()));
    }
    setState(() {
      global.secureMode = res;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 10,),
          Transform.scale(
              scale: 2,
            child: Switch(
              onChanged: secureModeToggle,
              value: global.secureMode,
              activeColor: Colors.white,
              activeTrackColor: Colors.green,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
