import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import '../core/AppController.dart';

class NativeCamera extends StatefulWidget {
  Function addPhoto;

  CameraDescription camera;
  NativeCamera({Key key, this.camera, this.addPhoto}) : super(key: key);

  @override
  _NativeCameraState createState() => _NativeCameraState();
}

class _NativeCameraState extends State<NativeCamera> {
  AppController _appController;

  CameraController _controller;
  Future<void> _initializeControllerFuture;

  String _imageDataStr;
  Uint8List _imageData;
  bool _snapped = false;
  bool _selectCameraOn = false;
  String _errorMessage;

  Map<String, String> _availableCameras = {};
  String _activeCamera;

  @override
  void initState() {
    super.initState();

// Ensure that plugin services are initialized so that `availableCameras()`
// can be called before `runApp()`

    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      ResolutionPreset.max,
      imageFormatGroup: ImageFormatGroup.yuv420,
      enableAudio: false
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
    WidgetsFlutterBinding.ensureInitialized();

    Timer(Duration(milliseconds: 1000), () {
      _controller.initialize();
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _appController = Provider.of<AppController>(context);
    bool orientationPortrairt =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width;

    return Container(
      color: Color(0xfffafafa),
      child: RotatedBox(
        quarterTurns: orientationPortrairt ? 0 : -1,
        child: Column(
          //direction: orientationPortrairt ? Axis.vertical : Axis.horizontal,
          children: [
            Expanded(
                child: _errorMessage != null
                    ? Text(_errorMessage ?? '') :
                _snapped ?
                Image.memory(
                  base64.decode(_imageDataStr),
                  fit: BoxFit.fitWidth,
                )
                    : FutureBuilder<void>(
                        future: _initializeControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            // If the Future is complete, display the preview.
                            return CameraPreview(_controller);
                          } else {
                            // Otherwise, display a loading indicator.
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        },
                      )),
            Row(
                //direction: orientationPortrairt ? Axis.horizontal : Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    child: Container(
                      padding: EdgeInsets.all(25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.undo, color: Color(0xff577ebb), size: 22),
                          SizedBox(height: 2),
                          Text(
                            'Back',
                            style:
                                TextStyle(color: Colors.black38, fontSize: 12),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      _appController.cameraOn = false;
                    },
                  ),
                  !_snapped
                      ? InkWell(
                          child: Icon(Icons.photo_camera_outlined,
                              color: Color(0xff577ebb), size: 45),
                          onTap: () async {
                            // Take the Picture in a try / catch block. If anything goes wrong,
                            // catch the error.
                            try {
                              // Ensure that the camera is initialized.
                              await _initializeControllerFuture;

                              // Attempt to take a picture and get the file `image`
                              // where it was saved.
                              final image = await _controller.takePicture();
                              var bytes = await image.readAsBytes();
                              _imageDataStr = base64Encode(bytes);
                              // If the picture was taken, display it on a new screen.

                            } catch (e) {
                              // If an error occurs, log the error to the console.
                              print(e);
                            }
                            if (_imageDataStr != null) {
                              setState(() {
                                _imageData = base64.decode(_imageDataStr);
                                _snapped = true;
                              });
                            }
                          },
                        )
                      : InkWell(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.check, color: Colors.green, size: 22),
                              SizedBox(height: 2),
                              Text(
                                'Save',
                                style: TextStyle(
                                    color: Colors.black38, fontSize: 12),
                              )
                            ],
                          ),
                          onTap: () {
                            try {
                              widget.addPhoto(_imageDataStr);
                              _appController.cameraOn = false;
                            } catch (e) {
                              setState(() {
                                _errorMessage = '164 \n' + e.toString();
                              });
                            }
                          },
                        ),
                  !_snapped
                      ? Container()
                      : InkWell(
                          child: Container(
                            padding: EdgeInsets.all(25),
                            child: _snapped
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(Icons.close,
                                          color: Colors.redAccent, size: 22),
                                      SizedBox(height: 2),
                                      Text(
                                        'Cancel',
                                        style: TextStyle(
                                            color: Colors.black38,
                                            fontSize: 12),
                                      )
                                    ],
                                  )
                                : Container(),
                          ),
                          onTap: () async {
                            try {
                              setState(() {
                                _controller.initialize();
                                _imageData = null;
                                _snapped = false;
                              });
                            } catch (e) {
                              setState(() {
                                _errorMessage = '256 \n' + e.toString();
                              });
                            }
                          },
                        ),
                ]),
          ],
        ),
      ),
    );
  }
}
