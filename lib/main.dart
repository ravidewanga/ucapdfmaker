import 'package:flutter/material.dart';
import 'package:ucapdfmaker/pages/camera.dart';
import 'package:ucapdfmaker/pages/gallery.dart';
import 'pages/home.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UCA - PDF Maker',
      theme: new ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        //accentColor: Color(0xfff19f34),
        appBarTheme:AppBarTheme(
          color: Colors.white,
          iconTheme: Theme.of(context).iconTheme,
        ),
      ),
      home: Home(),
      routes:{
        '/home': (BuildContext context) => Home(),
        '/camera': (BuildContext context) => Camera(),
        '/gallery': (BuildContext context) => Gallery(),
      },
    );
  }
}
