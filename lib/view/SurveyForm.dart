import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'TranslatedText.dart';

//Android / IOS
import 'package:camera/camera.dart';
import 'NativeCamera.dart';
import 'package:geolocator/geolocator.dart';

//web
//import 'dart:js' as js;
//import 'dart:html' as html;
//import 'WebCamera.dart';

import '../core/AppController.dart';
import '../data/DataStructure.dart';

class SurveyForm extends StatefulWidget {
  SurveyForm({Key key, this.farmerId, this.surveyName}) : super(key: key);

  final int farmerId;
  final String surveyName;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<SurveyForm> {
  AppController _appController;

  //Android / IOS
  CameraDescription _camera;

  List<SurveysQuestion> _questions = [];
  Map<String, TextEditingController> _textControlers = {};
  Map<String, String> _selectValues = {};
  List<String> _photos = [];
  List<String> _unfilledFields = [];
  Random _rnd = Random();

  DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
  DateFormat _dateTimeFormatter = DateFormat('yyyy-MM-dd H:m:s');

  bool _savingInProgress = false;

  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 100), () {
      setState(() {
        _questions = _appController.surveysQuestions.values
            .where((SurveysQuestion question) =>
                question.surveyName == widget.surveyName)
            .toList();
        _questions.forEach((SurveysQuestion question) {
          _textControlers[question.dataType] = TextEditingController();
        });
      });

      //Android / IOS
      _getCameras();

      if (_textControlers.keys.contains('Latitude')) _getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    _appController = Provider.of<AppController>(context);
    return Scaffold(
      appBar: AppBar(
        title: Container(
            width: MediaQuery.of(context).size.width*0.8,
            child: Row(
          children: [
            Flexible(child: TranslatedText(widget.surveyName)),
            Text(' '),
            TranslatedText('survey'),
          ],
        )),
      ),
      body: widget.farmerId == null || _appController.farmers[widget.farmerId] == null ?
      Container() : Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(10),
            child: _questions.length > 0
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(_appController.project +
                            ' > ' +
                            _appController.group,
                            style: TextStyle(color: Colors.blueAccent,
                                fontSize: 14)),
                        SizedBox(height: 5),
                        _appController
                            .farmers[widget.farmerId].subVillage != null &&
                            _appController
                                .farmers[widget.farmerId].name != null ?
                        Text(_appController
                            .farmers[widget.farmerId].subVillage +
                            ' > ' +
                            _appController
                                .farmers[widget.farmerId].name,
                            style: TextStyle(color: Colors.black87,
                                fontSize: 14)) :
                        Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                SizedBox(height: 10),
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      for (SurveysQuestion question in _questions)
                                        question == null
                                            ? Container()
                                            : Container(
                                                width: 300,
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      question.type != 'Location'
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 20,
                                                                      bottom: 5),
                                                              child: Row(
                                                                children: [
                                                              Flexible(child:TranslatedText(
                                                                    question.dataType,
                                                                    style: TextStyle(
                                                                        fontSize: 14,
                                                                        color: _unfilledFields.contains(
                                                                                question
                                                                                    .dataType)
                                                                            ? Colors
                                                                                .redAccent
                                                                            : Colors
                                                                                .blueAccent),
                                                                  )),
                                                        question.measurementUnit == '' ?
                                                            Container() :
                                                                  Row(
                                                                    children: [
                                                                      Text(' (',
                                                                          style: TextStyle(
                                                                              fontSize: 14,
                                                                              color: Colors.blueAccent)),
                                                                      TranslatedText(question.measurementUnit,
                                                                        style: TextStyle(
                                                                            fontSize: 14,
                                                                            color: Colors.blueAccent),
                                                                      ),
                                                                      Text(')',
                                                                          style: TextStyle(
                                                                              fontSize: 14,
                                                                              color: Colors.blueAccent)),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            )
                                                          : Container(),
                                                      question.type == 'Text'
                                                          ? CupertinoTextField(
                                                              controller:
                                                                  _textControlers[
                                                                      question
                                                                          .dataType], // Only numbers can be entered
                                                            )
                                                          : question.type ==
                                                                  'Number'
                                                              ? CupertinoTextField(
                                                                  controller:
                                                                      _textControlers[
                                                                          question
                                                                              .dataType],
                                                                  keyboardType: TextInputType
                                                                      .numberWithOptions(
                                                                          decimal:
                                                                              true), // Only numbers can be entered
                                                                  onChanged: (val) {
                                                                    _textControlers[question
                                                                                .dataType]
                                                                            .text =
                                                                        val.replaceAll(
                                                                            ',',
                                                                            '.');
                                                                    _textControlers[
                                                                                question
                                                                                    .dataType]
                                                                            .selection =
                                                                        TextSelection.fromPosition(TextPosition(
                                                                            offset: _textControlers[question.dataType]
                                                                                .text
                                                                                .length));
                                                                  },
                                                                )
                                                              : question.type ==
                                                                      'Date'
                                                                  ? CupertinoTextField(
                                                                      controller:
                                                                          _textControlers[
                                                                              question
                                                                                  .dataType],
                                                                      onTap: () {
                                                                        _showDatePicker(
                                                                            context,
                                                                            question
                                                                                .dataType);
                                                                      } // Only numbers can be entered
                                                                      )
                                                                  : question.type ==
                                                                          'Select'
                                                                      ? DropdownButton<
                                                                          String>(
                                                                          key: ValueKey(
                                                                              question.dataType + 'Dropdown'),
                                                                          value:
                                                                              _selectValues[question.dataType] ??
                                                                                  '',
                                                                          isDense:
                                                                              true,
                                                                          icon: Icon(
                                                                              Icons
                                                                                  .expand_more_rounded,
                                                                              color:
                                                                                  Color(0xff577ebb)),
                                                                          iconSize:
                                                                              26,
                                                                          style: TextStyle(
                                                                              color: Colors
                                                                                  .black87,
                                                                              fontSize:
                                                                                  12),
                                                                          elevation:
                                                                              1,
                                                                          underline:
                                                                              Container(
                                                                            height:
                                                                                0,
                                                                          ),
                                                                          onChanged:
                                                                              (String
                                                                                  newValue) {
                                                                            setState(
                                                                                () {
                                                                              _selectValues[question.dataType] =
                                                                                  newValue;
                                                                            });
                                                                          },
                                                                          items: [
                                                                            DropdownMenuItem<
                                                                                String>(
                                                                              value:
                                                                                  '',
                                                                              child:
                                                                                  Text(''),
                                                                            ),
                                                                            ...question
                                                                                .options
                                                                                .replaceAll(', ',
                                                                                    ',')
                                                                                .split(
                                                                                    ',')
                                                                                .map<DropdownMenuItem<String>>((String
                                                                                    option) {
                                                                              return DropdownMenuItem<
                                                                                  String>(
                                                                                value:
                                                                                    option,
                                                                                child: TranslatedText(option,
                                                                                    style: TextStyle(
                                                                                      fontSize: 16,
                                                                                    )),
                                                                              );
                                                                            }).toList()
                                                                          ],
                                                                        ) :
                                                      question.type ==
                                                          'Yes/No'
                                                          ? DropdownButton<
                                                          String>(
                                                        key: ValueKey(
                                                            question.dataType + 'Dropdown'),
                                                        value:
                                                        _selectValues[question.dataType] ??
                                                            '',
                                                        isDense:
                                                        true,
                                                        icon: Icon(
                                                            Icons
                                                                .expand_more_rounded,
                                                            color:
                                                            Color(0xff577ebb)),
                                                        iconSize:
                                                        22,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .black87,
                                                            fontSize:
                                                            12),
                                                        elevation:
                                                        1,
                                                        underline:
                                                        Container(
                                                          height:
                                                          0,
                                                        ),
                                                        onChanged:
                                                            (String
                                                        newValue) {
                                                          setState(
                                                                  () {
                                                                _selectValues[question.dataType] =
                                                                    newValue;
                                                              });
                                                        },
                                                        items: [
                                                          DropdownMenuItem<
                                                              String>(
                                                            value:
                                                            '',
                                                            child:
                                                            Text(''),
                                                          ),
                                                          ...['Yes', 'No']
                                                              .map<DropdownMenuItem<String>>((String
                                                          option) {
                                                            return DropdownMenuItem<
                                                                String>(
                                                              value:
                                                              option,
                                                              child: TranslatedText(option,
                                                                  style: TextStyle(
                                                                    fontSize: 16,
                                                                  )),
                                                            );
                                                          }).toList()
                                                        ],
                                                      )
                                                                      : question.type ==
                                                                              'Photos'
                                                                          ? Column(
                                                                              children: [
                                                                                  Column(children: [
                                                                                    for (String photoStr in _photos)
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                                                                                        child: Stack(children: [
                                                                                          Container(
                                                                                            width: 300,
                                                                                            child: Image.memory(
                                                                                              base64.decode(photoStr),
                                                                                              fit: BoxFit.fitWidth,
                                                                                            ),
                                                                                          ),
                                                                                          Positioned(
                                                                                              bottom: 5,
                                                                                              left: 5,
                                                                                              child: Row(
                                                                                                children: [
                                                                                                  FloatingActionButton(
                                                                                                      heroTag: 'btn_rotate_left' + _rnd.nextInt(10000).toString(),
                                                                                                      backgroundColor: Colors.white.withOpacity(0.6),
                                                                                                      child: Icon(Icons.rotate_left, color: Colors.black87, size: 20),
                                                                                                      mini: true,
                                                                                                      onPressed: () {
                                                                                                        final originalImage = img.decodeImage(base64.decode(photoStr));

                                                                                                        img.Image fixedImage;
                                                                                                        fixedImage = img.copyRotate(originalImage, -90);
                                                                                                        String newPhotoStr = base64.encode(img.encodeJpg(fixedImage));
                                                                                                        var index = _photos.indexWhere((element) => element == photoStr);
                                                                                                        setState(() {
                                                                                                          _photos[index] = newPhotoStr;
                                                                                                        });
                                                                                                      }),
                                                                                                  SizedBox(width: 5),
                                                                                                  FloatingActionButton(
                                                                                                      heroTag: 'btn_rotate_right' + _rnd.nextInt(10000).toString(),
                                                                                                      backgroundColor: Colors.white.withOpacity(0.6),
                                                                                                      child: Icon(Icons.rotate_right, color: Colors.black87, size: 20),
                                                                                                      mini: true,
                                                                                                      onPressed: () {
                                                                                                        final originalImage = img.decodeImage(base64.decode(photoStr));

                                                                                                        img.Image fixedImage;
                                                                                                        fixedImage = img.copyRotate(originalImage, 90);
                                                                                                        String newPhotoStr = base64.encode(img.encodeJpg(fixedImage));
                                                                                                        var index = _photos.indexWhere((element) => element == photoStr);
                                                                                                        setState(() {
                                                                                                          _photos[index] = newPhotoStr;
                                                                                                        });
                                                                                                      }),
                                                                                                ],
                                                                                              )),
                                                                                          Positioned(
                                                                                              top: 5,
                                                                                              right: 5,
                                                                                              child: FloatingActionButton(
                                                                                                  heroTag: 'btn_delete' + _rnd.nextInt(10000).toString(),
                                                                                                  backgroundColor: Colors.white.withOpacity(0.6),
                                                                                                  child: Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                                                                                  mini: true,
                                                                                                  onPressed: () {
                                                                                                    setState(() {
                                                                                                      _photos.remove(photoStr);
                                                                                                    });
                                                                                                  }))
                                                                                        ]),
                                                                                      )
                                                                                  ]),
                                                                                  _photos.length < 5
                                                                                      ? Padding(
                                                                                          padding: const EdgeInsets.only(top: 5),
                                                                                          child: InkWell(
                                                                                            child: Row(children: [
                                                                                              Icon(Icons.photo_camera_outlined, color: Color(0xff577ebb), size: 20),
                                                                                              SizedBox(width: 10),
                                                                                              TranslatedText('Add photo', style: TextStyle(color: Color(0xff577ebb)))
                                                                                            ]),
                                                                                            onTap: () {
                                                                                              _appController.cameraOn = true;
                                                                                            },
                                                                                          ),
                                                                                        )
                                                                                      : Container()
                                                                                ])
                                                                          : Container()
                                                    ]),
                                              )
                                    ]),
                                SizedBox(height: 20),
                                _unfilledFields.length > 0
                                    ? TranslatedText('Not all fields are full.',
                                        style: TextStyle(color: Colors.redAccent))
                                    : Container(),
                                SizedBox(height: 20),
                                FloatingActionButton.extended(
                                  heroTag: 'btn_save',
                                  onPressed: () {
                                    if(_savingInProgress) return;
                                    _savingInProgress = true;

                                    Map<String, dynamic> formMap = {};

                                    _textControlers.forEach(
                                        (key, value) => formMap[key] = value.text);
                                    _selectValues.forEach(
                                        (key, value) => formMap[key] = value);

                                    if (_photos.length > 0) {
                                      formMap['Photos'] = _photos;
                                    }

                                    //check for un-filled fields
                                    if (_unfilledFields.length == 0) {
                                      formMap.forEach((key, value) {
                                        if (value == '' &&
                                            ![
                                              'Remarks',
                                              'Latitude',
                                              'Longitude',
                                              'Photo'
                                            ].contains(key))
                                          setState(() {
                                            _unfilledFields.add(key);
                                          });
                                      });
                                    } else {
                                      _unfilledFields = [];
                                    }

                                    if (_unfilledFields.length == 0) {
                                      _appController.saveForm({
                                        'Surveyor': _appController.userName,
                                        'Farmer_ID': widget.farmerId,
                                        'Survey_type': widget.surveyName,
                                        'Date': _dateTimeFormatter
                                            .format(DateTime.now()),
                                        'answers': formMap
                                      });

                                      Navigator.pop(context);
                                    }

                                    _savingInProgress = false;
                                  },
                                  label: TranslatedText(_unfilledFields.length == 0
                                      ? 'SAVE'
                                      : 'Save anyway'),
                                  icon: const Icon(Icons.check),
                                ),
                                SizedBox(height: 40),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                : Container(),
          ),
          _appController.cameraOn
              ? Positioned.fill(child:
                  //Android / IOS
                      Container(
                        padding: const EdgeInsets.only(top: 15),
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: NativeCamera(
                  camera: _camera,
                  addPhoto: (String photoStr) {
                    setState(() {
                        _photos.add(photoStr);
                    });
                  },
                ),
                      )) : Container()

                  //Web

    /*
                  WebCamera(
                  addPhoto: (String photoStr) {
                    setState(() {
                      _photos.add(photoStr);
                    });
                  },
                ))

     */

        ],
      ),
    );
  }

  void _showDatePicker(ctx, String target) {
    var result = DateTime.now();
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Container(
              height: 400,
              color: Color.fromARGB(255, 255, 255, 255),
              child: Column(
                children: [
                  Container(
                    height: 300,
                    child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: result,
                        onDateTimeChanged: (val) {
                          result = val;
                        }),
                  ),

                  // Close the modal
                  CupertinoButton(
                      child: Text(
                        'OK',
                        style:
                            TextStyle(fontSize: 16, color: Colors.blueAccent),
                      ),
                      onPressed: () {
                        _textControlers[target].text =
                            _dateFormatter.format(result);
                        Navigator.of(ctx).pop();
                      })
                ],
              ),
            ));
  }

  //Web
  success(pos) {
    try {
      _textControlers['Latitude'].text =
          pos.coords.latitude.toStringAsFixed(10);
      _textControlers['Longitude'].text =
          pos.coords.longitude.toStringAsFixed(10);
    } catch (ex) {
      print("Exception thrown : " + ex.toString());
    }
  }

  Future<void> _getCurrentLocation() async {
    //Web
    //await html.window.navigator.geolocation.getCurrentPosition();
    //getCurrentPosition(js.allowInterop((pos) => success(pos)));
    /*
    js.context.callMethod('getLocation');
    Timer(Duration(milliseconds: 500), ()
    {
      var lat = js.context.callMethod('getLat');
      var lng = js.context.callMethod('getLng');

      if (lat != null && lng != null) {
        _textControlers['Latitude'].text =
            lat.toStringAsFixed(10);
        _textControlers['Longitude'].text =
            lng.toStringAsFixed(10);
      }
    });
    */
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  Position pos = await Geolocator.getCurrentPosition();
  //print(pos.latitude.toStringAsFixed(10));
  //print(pos.longitude.toStringAsFixed(10));
    _textControlers['Latitude'].text = pos.latitude.toStringAsFixed(10);
    _textControlers['Longitude'].text = pos.longitude.toStringAsFixed(10);
  }

//Android / IOS

  void _getCameras() async {
    List<CameraDescription> _cameras = <CameraDescription>[];
    try {
      WidgetsFlutterBinding.ensureInitialized();
      _cameras = await availableCameras();
    } on CameraException catch (e) {
      print(e);
    }
    _camera = _cameras.first;
  }


}
