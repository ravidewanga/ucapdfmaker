import 'dart:io';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'package:camera/camera.dart';
import 'package:audioplayers/audioplayers.dart';
import '../pages/image_list.dart';
import '../widgets/my_widgets.dart';
import '../services/global.dart' as global;

class Camera extends StatefulWidget {
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AudioCache _audioCache;
  bool _cameraOn = true;
  CameraController _controller;
  List<CameraDescription> _cameras;
  bool flash = false;

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[0], ResolutionPreset.veryHigh);
    _controller.initialize().then((_) {
      _controller.setFlashMode(FlashMode.off);
      if (!mounted) {
        return;
      }
      //update UI
      setState(() {});
    });
  }

  @override
  void initState() {
    setState(() {
      global.cameraImages = [];
    });
    _initCamera();
    super.initState();
    _audioCache = AudioCache(prefix: "audio/", fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP));
  }

  @override
  void dispose() {
    _controller?.dispose();
    setState(() {
      _cameraOn = false;
    });
    super.dispose();
  }

  Future<bool> onWillPop(){
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: loadingWidget(context),
        ),
      );
    } else {
      if (!_cameraOn) {
        return Container();
      } else {
        return WillPopScope(
          onWillPop: onWillPop,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.black,
            extendBody: true,
            appBar: AppBar(
              backgroundColor: Colors.black87,
              actions: [
                IconButton(
                    icon: Icon(
                      flash ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      setState(() {
                        flash = !flash;
                      });
                      flash
                          ? _controller.setFlashMode(FlashMode.always)
                          : _controller.setFlashMode(FlashMode.off);
                    }),
              ],
            ),
            body: Container(
              child: FutureBuilder<void>(
                builder: (context, snapshot) {
                  return CameraPreview(_controller);
                },
              ),
            ),
            bottomNavigationBar: _buildBottomNavigationBar(),
          ),
        );
      }
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      color: Colors.black,
      height: 100.0,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          FutureBuilder(
            future: getLastImage(),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Container(
                  // width: 40.0,
                  // height: 40.0,
                  // decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                );
              }
              return GestureDetector(
                onTap: finishCameraProcess,
                child: Badge(
                  badgeContent: Text(global.cameraClickCount.toString()),
                  child: Container(
                    width: 40.0,
                    height: 40.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Image.file(
                        snapshot.data,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 28.0,
            child: IconButton(
              icon: Icon(
                Icons.camera_alt,
                size: 30.0,
                color: Colors.black,
              ),
              onPressed: () {
                _captureImage();
              },
            ),
          ),
          global.cameraClickCount > 0 && global.cameraImages.length > 0 ?
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 23.0,
            child: TextButton(
              onPressed: finishCameraProcess,
              child: const Text('Next',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
            ),
          ) : Container(),
        ],
      ),
    );
  }

  finishCameraProcess() {
    if (global.cameraImages.length > 0) {
      for (var img in global.cameraImages) {
        global.imagesList.add(img);
      }
      _controller?.dispose();
      setState(() {
        _cameraOn = false;
      });
      Navigator.push(context,MaterialPageRoute(builder: (context) =>ImageList()));
    }
  }

  void _captureImage() async {
    if (_controller.value.isInitialized) {
      _controller.takePicture().then((XFile file)async {
        _audioCache.play('data_sounds_effects_camera_click.ogg');
        print('file path');
        print (file.path);
        if (mounted) {
          setState(() {
            global.cameraImages.add(File(file.path));
            global.cameraClickCount = global.cameraImages.length;
          });
        }
      });
    }
  }

  Future<FileSystemEntity> getLastImage() async {
    var lastFile = global.cameraImages.last;
    return lastFile;
  }
}
