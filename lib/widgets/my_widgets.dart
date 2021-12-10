import 'package:flutter/material.dart';
import '../services/global.dart' as global;

Widget loadingWidget (BuildContext context){
  return CircularProgressIndicator(
   // backgroundColor: global.primaryColor,
   // valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
  );
}

Widget homeLoadingWidget (BuildContext context){
  return Container(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(
      //backgroundColor: global.primaryColor,
      //valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
    ),
  );
}

Widget buttonWidget (BuildContext context,name,function,horizontal,vertical){
  return ElevatedButton(
    onPressed: function,
    child: Text(name,style: TextStyle(fontSize: 18)),
    style: TextButton.styleFrom(
      backgroundColor: global.primaryColor,
      primary: Colors.white,
      //minimumSize: Size(88, 36),
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(30.0)),
      ),
      //side: BorderSide(width: 1.5, color: Colors.white),
    ),
  );
}

Widget gridWidget (BuildContext context,name,function,horizontal,vertical){
  return ElevatedButton(
    onPressed: function,
    child: Text(name,style: TextStyle(fontSize: 18)),
    style: TextButton.styleFrom(
      backgroundColor: global.primaryColor,
      primary: Colors.white,
      //minimumSize: Size(88, 36),
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      //side: BorderSide(width: 1.5, color: Colors.white),
    ),
  );
}

Widget divider(BuildContext context){
  return Container(
    color: Colors.grey[300],
    height: 1.5,
  );
}

