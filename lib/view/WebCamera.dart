import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import '../core/AppController.dart';

class WebCamera extends StatefulWidget {
  Function addPhoto;

  WebCamera({Key key, this.addPhoto}) : super(key: key);

  @override
  _WebCameraState createState() => _WebCameraState();
}

class _WebCameraState extends State<WebCamera> {
  AppController _appController;
  final _mediaDevices = html.window.navigator.mediaDevices;
  static html.VideoElement _webcamVideoElement =
      html.document.getElementById('videoCam');
  //static html.Element _videoOuter = html.Element.div();
  //static html.Element _videoOuter2 = html.Element.div()
  //  ..style.position = 'relative';

  final _key = GlobalKey();
  int _zoom = 100;
  String _imageDataStr;
  Uint8List _imageData;
  bool _snaped = false;
  bool _selectCameraOn = false;
  String _error_message;

  Map<String, String> _availableCameras = {};
  String _activeCamera;

  @override
  void initState() {
    super.initState();

    try {
      _getMedia();
      Timer(Duration(seconds: 2), () {
        if (_activeCamera != _appController.defaultCamera &&
            _appController.defaultCamera != null) _getMedia();
      });
      // Register a webcam
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory('webcamVideoElement',
          (int viewId) {
        //_videoOuter.append(_webcamVideoElement);
        //_videoOuter.append(_videoOuter2);
        return _webcamVideoElement;
      });
    } catch (e) {
      setState(() {
        _error_message = '58 \n' + e.toString();
      });
    }
  }

  @override
  void dispose() {
    _switchCameraOff();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _appController = Provider.of<AppController>(context);
    bool orientationPortrairt =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width;
    try {
      return Container(
        color: Color(0xfffafafa),
        child: RotatedBox(
          quarterTurns: orientationPortrairt ? 0 : -1,
          child: Column(
            //direction: orientationPortrairt ? Axis.vertical : Axis.horizontal,
            children: [
              Expanded(
                  child: _error_message != null || _webcamVideoElement == null
                      ? Text(_error_message ?? '')
                      : RotatedBox(
                          quarterTurns: orientationPortrairt ? 0 : 1,
                          child: _imageData == null
                              ? HtmlElementView(
                                  key: _key,
                                  viewType: 'webcamVideoElement',
                                )
                              : Image.memory(
                                  _imageData,
                                  fit: BoxFit.fitWidth,
                                ),
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
                            Icon(Icons.undo,
                                color: Color(0xff577ebb), size: 22),
                            SizedBox(height: 2),
                            Text(
                              'Back',
                              style: TextStyle(
                                  color: Colors.black38, fontSize: 12),
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        _appController.cameraOn = false;
                      },
                    ),
                    !_snaped
                        ? InkWell(
                            child: Icon(Icons.photo_camera_outlined,
                                color: Color(0xff577ebb), size: 45),
                            onTap: () async {
                              try {
                                _webcamVideoElement.pause();
                                //final _size = _key.currentContext.size;
                                _imageDataStr = js.context.callMethod(
                                    'snapCamera', [
                                  _webcamVideoElement
                                ]).replaceAll('data:image/jpeg;base64,', '');
                              } catch (e) {
                                setState(() {
                                  _error_message = '134 \n' + e.toString();
                                });
                              }
                              if (_imageDataStr != null) {
                                setState(() {
                                  _imageData = base64.decode(_imageDataStr);
                                  _snaped = true;
                                });
                              }
                            },
                          )
                        : InkWell(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.check,
                                    color: Colors.green, size: 22),
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
                                  _error_message = '164 \n' + e.toString();
                                });
                              }
                            },
                          ),
                    (!_snaped) &&
                            _availableCameras.length > 0 &&
                            _availableCameras.keys.contains(_activeCamera)
                        ? _selectCameraOn
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(right: 25, top: 1),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (String camera
                                          in _availableCameras.keys)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 15),
                                          child: InkWell(
                                            child: Text(camera,
                                                style: TextStyle(
                                                    color:
                                                        camera == _activeCamera
                                                            ? Color(0xff577ebb)
                                                            : Colors.black87)),
                                            onTap: () {
                                              setState(() {
                                                _activeCamera = camera;
                                                _selectCameraOn = false;
                                              });

                                              _setActiveCamera();
                                              _appController.defaultCamera =
                                                  camera;
                                            },
                                          ),
                                        )
                                    ]),
                              )
                            : InkWell(
                                child: Container(
                                  padding: EdgeInsets.all(25),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(Icons.settings,
                                          color: Color(0xff577ebb), size: 22),
                                      SizedBox(height: 2),
                                      Text(
                                        'Cameras',
                                        style: TextStyle(
                                            color: Colors.black38,
                                            fontSize: 12),
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () async {
                                  setState(() {
                                    _selectCameraOn = true;
                                  });
                                },
                              )
                        : InkWell(
                            child: Container(
                              padding: EdgeInsets.all(25),
                              child: _snaped
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
                                  _imageData = null;
                                  _snaped = false;
                                });
                                _webcamVideoElement.play();
                              } catch (e) {
                                setState(() {
                                  _error_message = '256 \n' + e.toString();
                                });
                              }
                            },
                          ),
                  ]),
            ],
          ),
        ),
      );
    } catch (e) {}
  }

  _getMedia() async {
    try {
      var deviceInfos = await _mediaDevices.enumerateDevices();

      deviceInfos.forEach((deviceInfo) {
        if (deviceInfo.kind == 'videoinput') {
          String deviceLabel = deviceInfo.label;
          if (deviceInfo != null && !deviceLabel.contains(' front')) {
            setState(() {
              _availableCameras[deviceLabel] = deviceInfo.deviceId;
            });
          }
        }
      });

      setState(() {
        _activeCamera = _appController.defaultCamera != null &&
                _availableCameras.containsKey(_appController.defaultCamera)
            ? _appController.defaultCamera
            : _availableCameras.keys.first;
      });
    } catch (e) {
      setState(() {
        _error_message = '291 \n' + e.toString();
      });
    }

    _setActiveCamera();
  }

  _setActiveCamera({int attempts: 0}) async {
    _switchCameraOff();

    var videoConstrains = (_availableCameras == null ||
            _activeCamera == null ||
            _availableCameras[_activeCamera] == null ||
            _availableCameras[_activeCamera] == '')
        ? {'facingMode': 'environment'}
        : {
            'deviceId': {'exact': _availableCameras[_activeCamera]}
          };
    var constraints = {'audio': false, 'video': videoConstrains};

    try {
      var streamHandle = await _mediaDevices.getUserMedia(constraints);
      if (_webcamVideoElement == null || streamHandle == null) {
        print(attempts);
        _webcamVideoElement = html.VideoElement()..id = 'videoCam';
        if (attempts < 10)
          Timer(Duration(milliseconds: 100), () {
            setState(() {
              _setActiveCamera(attempts: attempts + 1);
            });
          });
        return;
      }
      _webcamVideoElement
        ..setAttribute('playsinline', 'true')
        ..srcObject = streamHandle
        ..autoplay = true;
    } catch (e) {
      setState(() {
        _error_message =
            '325 \n' + constraints.toString() + '\n' + e.toString();
      });
    }
  }

  _switchCameraOff() {
    try {
      if (_webcamVideoElement != null &&
          _webcamVideoElement.srcObject != null &&
          _webcamVideoElement.srcObject.active) {
        var tracks = _webcamVideoElement.srcObject.getTracks();
        //stopping tracks and setting srcObject to null to switch camera off
        _webcamVideoElement.srcObject = null;

        tracks.forEach((track) {
          track.stop();
        });
      }
    } catch (e) {
      setState(() {
        _error_message = '344 \n' + e.toString();
      });
    }
  }
}
