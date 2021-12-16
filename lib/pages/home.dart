import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:ucapdfmaker/pages/image_list.dart';
import '../pages/camera.dart';
import '../services/multipart_request.dart';
import '../services/api.dart' as api;
import '../services/global.dart' as global;
import '../widgets/my_widgets.dart';

class FileList{
  String fileName;
  String filePage;
  String fileSize;
  String createdAt;
  String filePath;
  int uploading;
  FileList(this.fileName,this.filePage,this.fileSize,this.createdAt,this.filePath,this.uploading);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Asset> images = <Asset>[];
  bool loader = true;
  List<FileList> files;
  PdfDocument document = PdfDocument();
  bool storagePermission = false;
  double uploadPercentage = 0.00;
  String uploadFileName = '';

  void getFiles() async {
    List<FileList> data = [];
    final dirPath = (await getExternalStorageDirectory())?.path;
    Directory dir = Directory(dirPath);
    final checkPathExistence = await Directory(dirPath).exists();
    if(checkPathExistence){
      List allContents = dir.listSync(recursive: true);
      for(var ff in allContents){
        var name = path.basename(ff.path);
        List splitName = name.split('.');
        if(splitName.last == 'pdf'){
          print(ff.path.toString());
          var pageCount = await getPageCount(ff.path);
          var fileSize = await getFileSize(ff.path, 1);
          var fileDate = await getFileCreationDate(ff.path);
          var filePath = ff.path.toString();
          FileList f = FileList(name,pageCount,fileSize,fileDate,filePath,0);
          data.add(f);
        }
      }
    }
    data.sort((a,b) {
      var adate = a.createdAt;
      var bdate = b.createdAt;
      return -adate.compareTo(bdate);
    });
    if (mounted) {
      setState(() {
        files = data;
        loader = false;
        storagePermission = true;
        global.imagesList = [];
        global.cameraImages = [];
      });
    }
  }

  deleteCache() async{
    await api.deleteCacheDir();
  }

  @override
  void initState() {
    getFiles();
    deleteCache();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: loader ? Center(
        child: loadingWidget(context),
      ):files.length == 0 ? Center(
        child: Text("No files found."),
      ):  Container(
        //padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                child: ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (BuildContext context,int index){
                    return Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading:  CircleAvatar(
                              backgroundColor: Theme.of(context).accentColor,
                              radius: 30,
                              child: Icon(Icons.picture_as_pdf_sharp,color: Colors.white,size: 30,),
                            ),
                            title: Text(files[index].fileName,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,),),
                            subtitle: Text('Pages: ${files[index].filePage} \nSize: ${files[index].fileSize}\nDate: ${files[index].createdAt}',style: TextStyle(fontSize: 16),),
                            trailing: files[index].uploading == 1 ? Container(
                              height: 15,
                              width: 15,
                              child: CircularProgressIndicator(),
                            ):null,
                            onTap: () {
                              OpenFile.open(files[index].filePath);
                            },
                          ),
                          SizedBox(height: 10,),

                          Divider(height: 1,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete,color: Colors.red,size: 30,),
                                tooltip: 'Delete',
                                onPressed: () => deleteFile(files[index].filePath),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cloud_upload,color: Colors.green,size: 30),
                                tooltip: 'Upload',
                                onPressed: () => {
                                  setState(() {
                                    uploadFileName = files[index].fileName;
                                  }),
                                  //_showUploadStatus(),
                                  showQROptions(index,files[index].filePath)
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:getFAB(context,loadAssets),
    );
  }

  void displayBottomSheet(BuildContext context) {
    Navigator.push(context,MaterialPageRoute(builder: (context) =>Camera()));
  }

  getFileSize(String filepath, int decimals) async {
    var file = File(filepath);
    int bytes = file.lengthSync();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +' ' + suffixes[i];
  }

  getPageCount(String filepath) async {
    document = PdfDocument(inputBytes: File(filepath).readAsBytesSync());
    int pageCount = document.pages.count;
    return pageCount.toString();
  }

  getFileCreationDate(String filepath) async {
    final stat = FileStat.statSync(filepath);
    var lastModified = DateFormat("dd-MM-yyyy HH:mm").format(stat.changed); // yyyy-MM-dd hh:mm:ss
    return lastModified.toString();
  }

  uploadPDF(index,filepath)async{
    Navigator.of(context).pop(false);
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.QR);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;

    if (barcodeScanRes.toString() != '-1') {
      setState(() {
        files[index].uploading = 1;
      });

      Uri uri = Uri.parse(barcodeScanRes.toString());
      List pathSegments = uri.pathSegments;
      var userId = pathSegments[3];
      var qId = pathSegments[4];
      var logId = pathSegments[5];
      var screenNo = pathSegments[6];
      String expires = uri.queryParameters['expires'];

      print('userId $userId');
      print('qId $qId');
      print('logId $logId');
      print('screenNo $screenNo');
      print('host ${uri.host}');
      print('expires $expires');

      String uploadUrl = 'https://${uri.host}/onlineexam/public/api/upload-answer';
      final request = MultipartRequest('POST',Uri.parse(uploadUrl),
        onProgress: (int bytes, int total) {
          final progress = bytes / total;
          setState(() {
            uploadPercentage = progress;
          });
          print('progress: $progress ($bytes/$total)');
        },
      );

      request.headers['HeaderKey'] = '';
      request.fields['user_id'] = userId;
      request.fields['q_id'] = qId;
      request.fields['log_id'] = logId;
      request.fields['screen'] = screenNo;
      request.fields['expires'] = expires;

      request.files.add(await http.MultipartFile.fromPath('student_file',filepath,
        contentType: MediaType('application', 'pdf'),),
      );

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      var res = jsonDecode(respStr);
      print(res);
      if(response.statusCode == 200){
        setState(() {
          files[index].uploading = 2;
        });
        _showUploadStatus();
      }else{
        setState(() {
          files[index].uploading = 2;
        });
        Fluttertoast.showToast(
            msg: res['msg'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }else{
      setState(() {
        files[index].uploading = 2;
      });
      Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  Future<File> changeFileNameOnly(File file, String newFileName) {
    var path = file.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName;
    return file.rename(newPath);
  }

  Future<void> _showUploadStatus() async {
    return showDialog<void>(
      context: context,
      //barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          //title: const Text(' Uploaded Successfully.',style: TextStyle(fontSize: 18),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$uploadFileName\nUploaded Successfully.',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
              Image.asset('images/success.gif'),
            ],
          ),
        );
      },
    );
  }

  showQROptions(index,filepath){
    return showDialog<void>(
      context: context,
      //barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title:Text('Scan the QR Code shown in your online examination for uploading this file.',
            style: TextStyle(fontSize: 14,),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(width: 100, height: 50),
                child: ElevatedButton(
                  onPressed: () => uploadPDF(index, filepath),
                  child: Row(
                    children: [
                      Icon(Icons.qr_code,color: Colors.white,size: 20,),
                      Text(' Scan',style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: global.primaryColor,
                    primary: Colors.white,
                    //minimumSize: Size(20, 50),
                    //padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                    //side: BorderSide(width: 1.5, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  deleteFile(filepath){
    return showDialog<void>(
      context: context,
      //barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
            title:Text('Are you sure? You want to delete this file.',style: TextStyle(fontSize: 16),),
            actions: <Widget>[
              TextButton(
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
                child: new Text('Yes',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.blue),),
                onPressed: () async{
                  final file = File(filepath);
                  await file.delete();
                  getFiles();
                  Navigator.of(context).pop(false);
                },
              ),
            ]
        );
      },
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 50,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#3866ab",
          actionBarTitle: "UCanEvaluate",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      print(e);
      //error = e.toString();
    }
    if (!mounted) return;

    if(resultList.length > 0){
      for (var img in resultList) {
        var path2 = await FlutterAbsolutePath.getAbsolutePath(img.identifier);
        var file = await getImageFileFromAsset(path2);
        global.imagesList.add(File(file.path));
      }
      Navigator.push(context,MaterialPageRoute(builder: (context) =>ImageList()));
    }
  }

  getImageFileFromAsset(String path) async{
    final file = File(path);
    return file;
  }
}
