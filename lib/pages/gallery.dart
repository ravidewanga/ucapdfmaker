import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:ucapdfmaker/pages/image_list.dart';
import '../services/global.dart' as global;

class Gallery extends StatefulWidget {
  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  List<Asset> images = <Asset>[];
  int pageAllowed = 32;

  @override
  void initState() {
    super.initState();
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: pageAllowed,
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: MediaQuery. of(context). size. width,
      child: Center(
        child:  FlatButton(
          minWidth: MediaQuery. of(context). size. width ,
          child: Text('Gallery'),
          //color: Colors.black,
          onPressed: loadAssets,
        ),
      ),
    );
  }
}
