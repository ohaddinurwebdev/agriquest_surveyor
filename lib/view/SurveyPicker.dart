import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../core/AppController.dart';
import '../data/DataStructure.dart';
import 'SurveyForm.dart';
import 'NotificationsList.dart';
import 'TranslatedText.dart';

class SurveyPicker extends StatefulWidget {
  SurveyPicker({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<SurveyPicker> {
  AppController _appController;

  String _selectedVillage = '';
  String _selectedSubVillage = '';
  int _selectedFarmerId;

  @override
  Widget build(BuildContext context) {
    _appController = Provider.of<AppController>(context);
    return Scaffold(
      appBar: AppBar(
        title: Container(
            width: MediaQuery.of(context).size.width*0.8,
            child: TranslatedText('New survey')),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(10),
        child: _appController.noData
            ? TranslatedText(
            'No data available,\n please connect to the web to load data.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey, fontSize: 18)) :
            Stack(children: [
              SingleChildScrollView(
            child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_appController.project +
                            ' > ' +
                            _appController.group,
                            style: TextStyle(color: Colors.blueAccent,
                                fontSize: 14)),

                        _appController.notifications.length > 0 ?
                        InkWell(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      NotificationsList()),
                            );
                          },
                          child: Column(
                            children: [
                              Container(
                                height: 33,
                                width: 33,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                        child: Icon(Icons.message_outlined,
                                            color: Colors.blueAccent,
                                            size: 26)),
                                    _appController.unreadNotificationsCount > 0 ?
                                    Positioned(
                                        top: 0,
                                        right: 0,
                                        child:
                                        Container(
                                            height: _appController.unreadNotificationsCount < 10 ? 15 : 18,
                                            width: _appController.unreadNotificationsCount < 10 ? 15 : 18,
                                            decoration: BoxDecoration(
                                                color: Colors.redAccent,
                                                border: Border.all(
                                                  color: Colors.redAccent,
                                                ),
                                                borderRadius: BorderRadius.all(Radius.circular(9))
                                            ),
                                            child: Center(
                                              child: Text(_appController.unreadNotificationsCount.toString(),
                                                  style: TextStyle(color: Colors.white, fontSize: 10)),
                                            )
                                        )
                                    ) : Container()
                                  ],
                                ),
                              ),
          TranslatedText('Notifications',
          style: TextStyle( color: Colors.black87, fontSize: 10),)
                            ],
                          ),
                        ) : Container()
                      ],
                    ) ,
                    SingleChildScrollView(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20),
                              TranslatedText('Select farmer:',
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(color: Colors.grey, fontSize: 16)),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  TranslatedText(
                                    'Village:',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.blueAccent),
                                  ),
                                  SizedBox(width: 10),
                                  DropdownButton<String>(
                                    key: ValueKey('villagesDropdown'),
                                    value: _selectedVillage,
                                    isDense: true,
                                    icon: Icon(Icons.expand_more_rounded,
                                        color: Color(0xff577ebb)),
                                    iconSize: 26,
                                    style: TextStyle(
                                        color: Colors.black87, fontSize: 12),
                                    elevation: 1,
                                    underline: Container(
                                      height: 0,
                                    ),
                                    onChanged: (String newValue) {
                                      setState(() {
                                        _selectedVillage = newValue;
                                        _selectedSubVillage = '';
                                        _selectedFarmerId = null;
                                      });
                                    },
                                    items: _getDistinctVillagesList()
                                        .map<DropdownMenuItem<String>>(
                                            (String village) {
                                      return DropdownMenuItem<String>(
                                        value: village,
                                        child: Text(village,
                                            style: TextStyle(
                                              fontSize: 14,
                                            )),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              _selectedVillage == ''
                                  ? Container()
                                  : Row(
                                      children: [
                                        TranslatedText(
                                          'Sub village:',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.blueAccent),
                                        ),
                                        SizedBox(width: 10),
                                        DropdownButton<String>(
                                          key: ValueKey('subVillagesDropdown'),
                                          value: _selectedSubVillage,
                                          isDense: true,
                                          icon: Icon(Icons.expand_more_rounded,
                                              color: Color(0xff577ebb)),
                                          iconSize: 26,
                                          style: TextStyle(
                                              color: Colors.black87, fontSize: 12),
                                          elevation: 1,
                                          underline: Container(
                                            height: 0,
                                          ),
                                          onChanged: (String newValue) {
                                            setState(() {
                                              _selectedSubVillage = newValue;
                                              _selectedFarmerId = null;
                                            });
                                          },
                                          items: _getDistinctSubVillagesList()
                                              .map<DropdownMenuItem<String>>(
                                                  (String subVillage) {
                                            return DropdownMenuItem<String>(
                                              value: subVillage,
                                              child: Text(subVillage,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  )),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                              SizedBox(height: 10),
                              _selectedSubVillage == ''
                                  ? Container()
                                  : Row(
                                      children: [
                                        TranslatedText(
                                          'Farmer:',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.blueAccent),
                                        ),
                                        SizedBox(width: 10),
                                        DropdownButton<int>(
                                          key: ValueKey('farmerssDropdown'),
                                          value: _selectedFarmerId,
                                          isDense: true,
                                          icon: Icon(Icons.expand_more_rounded,
                                              color: Color(0xff577ebb)),
                                          iconSize: 26,
                                          style: TextStyle(
                                              color: Colors.black87, fontSize: 12),
                                          elevation: 1,
                                          underline: Container(
                                            height: 0,
                                          ),
                                          onChanged: (int newValue) {
                                            setState(() {
                                              _selectedFarmerId = newValue;
                                            });
                                          },
                                          items: _getDistinctFarmersList()
                                              .map<DropdownMenuItem<int>>(
                                                  (int farmerId) {
                                            return DropdownMenuItem<int>(
                                              value: farmerId,
                                              child: Text(
                                                  farmerId == null
                                                      ? ''
                                                      : _appController
                                                          .farmers[farmerId].name,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  )),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                              SizedBox(height: 30),
                              _selectedFarmerId == null
                                  ? Container()
                                  : _appController.surveysQuestions.length == 0 ?
                              TranslatedText(
                                  'No available surveys.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 18)) :
                                Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                          for (String surveyName
                                              in _getDistinctSurveys())
                                            surveyName == ''
                                                ? Padding(
                                                    padding: const EdgeInsets.only(
                                                        bottom: 10),
                                                    child: TranslatedText('Select survey:',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 16)),
                                                  )
                                                : Container(
                                                    //width: 230,
                                                    padding: const EdgeInsets.only(
                                                        bottom: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        InkWell(
                                                          child: Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical: 5,
                                                                      horizontal:
                                                                          10),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0xfff1f1f1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4),
                                                                border: Border.all(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade300),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.3),
                                                                    spreadRadius: 1,
                                                                    blurRadius: 2,
                                                                    offset: Offset(
                                                                        1,
                                                                        1), // changes position of shadow
                                                                  ),
                                                                ],
                                                              ),
                                                              child: TranslatedText(
                                                                  surveyName,
                                                                  style: TextStyle(
                                                                      color: !(_existingSurveyDates(_selectedFarmerId, surveyName) !=
                                                                                  '' &&
                                                                              surveyName ==
                                                                                  'Base line')
                                                                          ? Colors
                                                                              .blueAccent
                                                                          : Colors
                                                                              .grey,
                                                                      fontSize:
                                                                          12))),
                                                          onTap: () {
                                                            if (!(_existingSurveyDates(
                                                                        _selectedFarmerId,
                                                                        surveyName) !=
                                                                    '' &&
                                                                surveyName ==
                                                                    'Base line'))
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            SurveyForm(
                                                                              farmerId:
                                                                                  _selectedFarmerId,
                                                                              surveyName:
                                                                                  surveyName,
                                                                            )),
                                                              );
                                                            Timer(
                                                                Duration(
                                                                    seconds: 1),
                                                                () {
                                                                  setState((){
                                                                    _selectedFarmerId = null;});
                                                            });
                                                          },
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text(_existingSurveyDates(
                                                                _selectedFarmerId,
                                                                surveyName) ??
                                                            '')
                                                      ],
                                                    ),
                                                  )
                                        ])
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                )),
                Positioned.fill(
                  child: _appController.dialogMessage == ''
                      ? Container()
                      : Container(
                          color: Color(0xffcccccc).withOpacity(0.7),
                          child: CupertinoAlertDialog(
                              content: Text(_appController.dialogMessage ?? '',
                                  style: TextStyle(
                                      color: Colors.black87, fontSize: 14)),
                              actions: <Widget>[
                                //Only one button
                                CupertinoDialogAction(
                                  isDefaultAction: true,
                                  child: TranslatedText('OK'),
                                  textStyle: TextStyle(fontSize: 14),
                                  onPressed: () {
                                    _appController.dialogMessage = '';
                                  },
                                ),
                              ]),
                        ),
                ),
                Positioned.fill(
                  child: _appController.loading
                      ? Container(
                          color: Color(0xffcccccc).withOpacity(0.7),
                          child: Center(
                            child: CupertinoActivityIndicator(radius: 20),
                          ))
                      : Container(),
                )
              ]),
      ),
    );
  }

  List<String> _getDistinctVillagesList() {
    List list = _appController.farmers.values
        .map((Farmer farmer) => farmer.village)
        .toSet()
        .toList();
    list.sort();
    return ['', ...list];
  }

  List<String> _getDistinctSubVillagesList() {
    List list = _appController.farmers.values
        .where((Farmer farmer) => farmer.village == _selectedVillage)
        .map((Farmer farmer) => farmer.subVillage)
        .toSet()
        .toList();
    list.sort();
    return ['', ...list];
  }

  List<int> _getDistinctFarmersList() {
    List<Farmer> farmersList = _appController.farmers.values
        .where((Farmer farmer) => farmer.subVillage == _selectedSubVillage)
        .toSet()
        .toList();
    farmersList.sort((Farmer a, Farmer b) => a.name.compareTo(b.name));
    List<int> resultList =
        farmersList.map((Farmer farmer) => farmer.farmerId).toList();
    return [null, ...resultList];
  }

  List<String> _getDistinctSurveys() {
    List list = _appController.surveysQuestions.values
        .map((SurveysQuestion surveysQuestions) => surveysQuestions.surveyName)
        .toSet()
        .toList();
    list.sort();
    return ['', ...list];
  }

  String _existingSurveyDates(int farmerId, String surveyType) {
    List<Survey> surveys = _appController.surveys
        .where((Survey survey) =>
            survey.farmerId == farmerId && survey.surveyType == surveyType)
        .toList();
    List<String> dates =
        surveys.map((Survey survey) => survey.date.split(' ')[0]).toList();
    return dates.join('\n');
  }
}
