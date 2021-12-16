import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ucapdfmaker/pages/Home_pdf.dart';
import 'pages/pdf_list.dart';
import 'pages/scan_to_pdf.dart';
import 'pages/upload_pdf.dart';
import 'pages/home.dart';
import 'pages/prohibited_app_list.dart';
import 'pages/options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();
  await Permission.microphone.request();
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
        accentColor: Color(0xfff19f34),
        appBarTheme:AppBarTheme(
          color: Colors.white,
          iconTheme: Theme.of(context).iconTheme,
        ),
      ),
      home: HomePage(),
      builder: EasyLoading.init(),
      routes:{
        '/home': (BuildContext context) => Home(),
        '/prohibited_app_list': (BuildContext context) => ProhibitedAppList(),
        '/options_page': (BuildContext context) => Options(),
        '/pdf_list': (BuildContext context) => PdfListPage(),
        '/scan_to_pdf': (BuildContext context) => ScanToPdf(),
        '/upload_pdf': (BuildContext context) => UploadPdf(),
      },
    );
  }
}
