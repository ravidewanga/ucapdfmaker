import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../services/global.dart' as global;

Widget loadingWidget (BuildContext context){
  return CircularProgressIndicator(
    // backgroundColor: global.primaryColor,
    // valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
  );
}

Widget getFAB(BuildContext context,loadAssets) {
  return SpeedDial(
    animatedIconTheme: IconThemeData(size: 22),
    backgroundColor:global.primaryColor,
    visible: true,
    curve: Curves.bounceIn,
    icon: Icons.add,
    activeIcon: Icons.close,
    spacing: 3,
    childPadding: const EdgeInsets.all(5),
    spaceBetweenChildren: 4,
    children: [
      // FAB 1
      SpeedDialChild(
          child: Icon(Icons.image,color: Colors.white,),
          backgroundColor: global.primaryColor,
          onTap:loadAssets,
          label: 'Gallery',
          labelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontSize: 16.0),
          labelBackgroundColor: global.primaryColor
      ),
      // FAB 2
      SpeedDialChild(
          child: Icon(Icons.camera,color: Colors.white,),
          backgroundColor: global.primaryColor,
          onTap: () => Navigator.of(context).pushNamed('/camera'),
          label: 'Camera',
          labelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontSize: 16.0),
          labelBackgroundColor: global.primaryColor
      ),
    ],
  );
}


