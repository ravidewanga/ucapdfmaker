import 'dart:io';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:flutter/rendering.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:ucapdfmaker/pages/home.dart';
 import '../services/api.dart' as api;
import '../services/global.dart' as global;
import '../widgets/my_widgets.dart';

class ImageList extends StatefulWidget {

  @override
  _ImageListState createState() => _ImageListState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class _ImageListState extends State<ImageList> {
  List<Asset> images = <Asset>[];
  FocusNode focusNode = new FocusNode();
  final _textFieldController = TextEditingController();
  final GlobalKey<FormState> _fileNameFormKey = GlobalKey<FormState>();
  ScrollController _scrollController;
  List<File> _compressedFile = [];
  bool _isInAsyncCall = false;
  AppState state;
  int variableSet = 0;
  double width;
  double height;
  var filename;
  String errorMsg = '';
  StateSetter  _setState;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: ModalProgressHUD(
        child: buildImageList(context),
        inAsyncCall: _isInAsyncCall,
        opacity: 0.5,
        progressIndicator: loadingWidget(context),
      ),
    );
  }

  Widget buildImageList(BuildContext context) {
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
            //iconTheme: IconThemeData(color: global.primaryColor),
            title: Image.asset('images/header_logo.png',fit: BoxFit.contain,height: 45,),
            actions: [
              Container(
                padding: EdgeInsets.all(10),
                child: ClipOval(
                  child: Material(
                    color: global.primaryColor, // Button color
                    elevation: 5,
                    child: InkWell(
                      splashColor: Colors.green, // Splash color
                      onTap: () => _createPopUp(context),
                      child: SizedBox(
                        width: 37,
                        height: 37,
                        child: Container(
                          padding: EdgeInsets.only(left: 5,top: 10),
                          child: Text('Save',style: TextStyle(fontSize: 12,color: Colors.white,fontWeight: FontWeight.bold),),
                        ),
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
      body: Container(
        child: global.imagesList.length > 0
            ? DragAndDropGridView(
          controller: _scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 4.5,
          ),
          padding: EdgeInsets.all(5),
          itemBuilder: (context, index) => Card(
            elevation: 2,
            child: LayoutBuilder(
              builder: (context, costrains) {
                if (variableSet == 0) {
                  height = costrains.maxHeight;
                  width = costrains.maxWidth;
                  variableSet++;
                }
                return GridTile(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          _cropImage(
                              global.imagesList[index].path, index);
                        },
                        child: Image.file(global.imagesList[index],
                            filterQuality: FilterQuality.low,
                            fit: BoxFit.cover,
                            height: 200,
                            width: width),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.menu),
                                SizedBox(
                                  width: 2,
                                ),
                                Text('Page ' + (index + 1).toString(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                              ],
                            ),
                            InkWell(
                              onTap: () => removeFile(index),
                              child: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          itemCount: global.imagesList.length,
          onWillAccept: (oldIndex, newIndex) {
            // Implement you own logic
            // Example reject the reorder if the moving item's value is something specific
            if (global.imagesList[newIndex].toString() == "something") {
              return false;
            }
            return true; // If you want to accept the child return true or else return false
          },
          onReorder: (oldIndex, newIndex) {
            final temp = global.imagesList[oldIndex];
            global.imagesList[oldIndex] = global.imagesList[newIndex];
            global.imagesList[newIndex] = temp;
            setState(() {});
          },
        ) : Container(),
      ),
      floatingActionButton:getFAB(context,loadAssets),
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
      //barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: new Text('Are you sure? You want to exit.',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
        actions: <Widget>[
          TextButton(
            onPressed: () => {Navigator.of(context).pop(false)},
            child: new Text('Cancel',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.grey),),
          ),
          TextButton(
            onPressed: () => goBack(),
            child: new Text('Yes',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: global.primaryColor),),
          ),
        ],
      ),
    ) ??
        false;
  }

  goBack() async{
    setState(() {
      global.imagesList = [];
    });
    //-------------**************-----------------
    Navigator.push(context,MaterialPageRoute(builder: (context) => Home()));
  }

  Future<void> _createPopUp(BuildContext context) async {
    setState(() {
      errorMsg = '';
    });
    return await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            _setState = setState;
            return AlertDialog(
              title: Text('Save PDF'),
              content: Container(
                child: Form(
                  key: _fileNameFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        key: Key('filename'),
                        decoration: InputDecoration(
                          hintText: "Enter file name",
                          labelText: "Enter file name",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0)
                          ),
                        ),
                        validator: validateFileName,
                        onSaved: (value) => filename = value,
                      ),
                      SizedBox(height: 2),
                      errorMsg != '' ? Text(errorMsg,style: TextStyle(color: Colors.red),):SizedBox(),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => {Navigator.of(context).pop(false)},
                  child: new Text('Cancel',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.grey),),
                ),
                TextButton(
                  onPressed: () => global.imagesList.length > 0 ? startPdfCreationProcess() : null,
                  child: Text('Submit',style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: global.primaryColor,
                    fontSize: 16,
                  ),
                  ),
                ),
              ],
            );
          });
        });
  }

  Future<Null> _cropImage(copImg, i) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: copImg,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      global.imagesList[i] = croppedFile;
      setState(() {
        state = AppState.cropped;
      });
    }
  }

  removeFile(int index) {
    setState(() {
      global.imagesList.removeAt(index);
    });
  }

  startPdfCreationProcess() async{
    if (!_fileNameFormKey.currentState.validate()) {
      return;
    }else{
      _fileNameFormKey.currentState.save();
      bool checkFileName =  await api.checkFileName(filename);
      if(!checkFileName){
        Navigator.of(context).pop(false);
        setState(() {
          _isInAsyncCall = true;
        });
        Future.delayed(Duration(seconds: 1), () {
          compressFile();
        });
      }else{
        _setState(() {
          errorMsg ="File name already exist.";
        });
      }
    }
  }

  compressFile() async {
    _compressedFile = [];
    for (var img in global.imagesList) {
      File compressedFile = await FlutterNativeImage.compressImage(img.path,
          quality: 70, percentage: 100);
      print(compressedFile.path);
      _compressedFile.add(File(compressedFile.path));
    }
    print('_compressedFile $_compressedFile');
    _createPDF();
  }

  Future<void> _createPDF() async {
    PdfDocument document = PdfDocument();
    final page = document.pages.add();
    //page.graphics.drawString(global.bookletName, PdfStandardFont(PdfFontFamily.helvetica, 30));
    int pageNo = 1;
    for (var img in _compressedFile) {
      if (pageNo == 1) {
        page.graphics.drawImage(
          PdfBitmap(File(img.path).readAsBytesSync()),
          Rect.fromLTWH(0, 0, page.getClientSize().width, page.getClientSize().height),
        );
      } else {
        document.pages.add().graphics.drawImage(
          PdfBitmap(File(img.path).readAsBytesSync()),
          Rect.fromLTWH(0, 0, page.getClientSize().width,page.getClientSize().height),
        );
      }
      pageNo++;
    }
    List<int> bytes = document.save();
    document.dispose();
    var path = await getExternalStorageDirectory();
    print('path is $path');
    var name = filename + '.pdf';
    final dirPath = (await getExternalStorageDirectory())?.path;

    Directory(dirPath).create().then((Directory directory) {
      final file = File('$dirPath/$name');
      print('file path $file');
      file.writeAsBytes(bytes, flush: true);
    });
    await api.removeCompressedFile();
    _isInAsyncCall = false;
    Navigator.push(context,MaterialPageRoute(builder: (context) => Home()));
  }

  String validateFileName(String filename){
    if(filename.isEmpty){
      return "This field is required.";
    }
    return null;
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
