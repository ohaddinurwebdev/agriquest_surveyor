import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'http.dart';
import 'dart:async';

//android / ios
import 'package:path_provider/path_provider.dart';

import '../data/DataStructure.dart';

class AppController extends ChangeNotifier {
  String baseUrl = 'https://fdms.pest-watch.com/';
                  //'https://webdev-solutions.com/FDMS/';
                  //'http://localhost/home/ohad/Websites/FDMS/public/';

  Box _storage;
  Http _http;
  Timer _sendWhenConnectedTimer;
  bool _gotData = false;
  bool noData = false;
  String loginError;

  String _userName;
  get userName => _userName;
  set userName(String name) {
    _userName = name;
    _storage.put('userName', _userName);
    notifyListeners();
  }

  String _password;
  get password => _password;
  set password(String password) {
    _password = password;
    _storage.put('password', _password);
    notifyListeners();
  }

  String _language = 'English';
  get language => _language;
  set language(String language) {
    _language = language;
    _storage.put('language', _language);
    notifyListeners();
  }

  Permissions permissions;
  String _project;
  String get project => _project;
  String _group;
  String get group => _group;

  Map<int, Farmer> _farmers = {};
  get farmers {
    Map<int, Farmer> filteredFarmers = {};
    _farmers.entries
        .where((element) =>
            element.value.project == _project && element.value.group == _group)
        .forEach((entry) {
      filteredFarmers[entry.key] = entry.value;
    });
    return filteredFarmers;
  }

  Map<int, SurveysQuestion> _surveysQuestions = {};
  get surveysQuestions {
    Map<int, SurveysQuestion> filteredSurveysQuestions = {};
    _surveysQuestions.entries
        .where((element) =>
            [_project, 'ALL'].contains(element.value.project) &&
            [_group, 'ALL'].contains(element.value.group))
        .forEach((entry) {
      filteredSurveysQuestions[entry.key] = entry.value;
    });

    return filteredSurveysQuestions;
  }

  Set<Survey> _surveys = {};
  get surveys => _surveys
      .where((element) =>
          [_project, 'ALL'].contains(element.project) &&
          [_group, 'ALL'].contains(element.group))
      .toList();

  List<Map<String, dynamic>> _unsentSurveys = [];
  get unsavedCount => _unsentSurveys.length;

  List<FdmsNotification> _notifications = [];
  List<FdmsNotification> get notifications =>_notifications;

  Set<int> _readNotificationsIds = {};
  bool notificationIsRead(int messageId){
    return _readNotificationsIds.contains(messageId);
  }
  void setNotificationAsRead(int messageId){
    _readNotificationsIds.add(messageId);
    _storage.put('readNotificationsIds', _readNotificationsIds.map((id) => id.toString()).toList());
    notifyListeners();
  }
  int get unreadNotificationsCount =>
      _notifications.where((FdmsNotification message) =>
                  ! notificationIsRead(message.id)).length;

  List<Translation> _translations = [];

  bool _cameraOn = false;
  get cameraOn => _cameraOn;
  set cameraOn(bool on) {
    _cameraOn = on;
    notifyListeners();
  }

  String _defaultCamera = '';
  get defaultCamera => _defaultCamera;
  set defaultCamera(String camera) {
    _defaultCamera = camera;
    _storage.put('defaultCamera', camera);
    notifyListeners();
  }

  String _dialogMessage = '';
  get dialogMessage => _dialogMessage;
  set dialogMessage(String message) {
    _dialogMessage = message;
    notifyListeners();
  }

  bool _loading = false;
  get loading => _loading;
  set loading(bool val) {
    _loading = val;
    notifyListeners();
  }

  AppController() {
    _http = Http(baseUrl);
  }

  void initApp() async {
    await _initStorage();
    await _getData();

    notifyListeners();
  }

  Future<void> _initStorage() async {
    //android / ios
    final documentDirectory = await getApplicationDocumentsDirectory();
    Hive.init(documentDirectory.path);

    _storage = await Hive.openBox('fdms_data');

    //_storage.clear();

    login(
        userName: _storage.get('userName'), password: _storage.get('password'));

    _defaultCamera = _storage.get('defaultCamera');

    List<dynamic> unsentSurveysList = _storage.get('unsentSurveys');
    if (unsentSurveysList != null) {
      unsentSurveysList.forEach((unsentSurveyLinkedMap) {
        var unsentSurvey = _linkedMapToMap(unsentSurveyLinkedMap);
        _unsentSurveys.add(unsentSurvey);
      });
      _sendWhenConnected();
    }
    return;
  }

  Future<bool> login({String userName, String password}) async {
    if (userName == null ||
        userName == '' ||
        password == null ||
        password == '') return false;

    var connected = await _http.isConnected();
    if (connected) {
      Map<String, dynamic> response =
          await _http.login(userName: userName, password: password);
      if (response['status'] == 'OK') {
        permissions = Permissions.fromMap(response['permissions']);
        _storage.put('userName', userName);
        _storage.put('password', password);
        _storage.put('permissions', permissions.toMap());
      } else {
        _userName = null;
        _password = null;
        loginError = response['error'];
        notifyListeners();
        return false;
      }
    }

    if (permissions == null) {
      Map<String, dynamic> permissionsMap = _storage.get('permissions');
      if (permissionsMap != null)
        permissions = Permissions.fromMap(permissionsMap);
    }

    if (permissions != null) {
      _userName = userName;
      _password = password;
      notifyListeners();
    }
    return permissions != null;
  }

  void logout() {
    _userName = null;
    _password = null;
    permissions = null;
    _project = null;
    _group = null;
    _http = Http(baseUrl);

    _storage.put('userName', null);
    _storage.put('password', null);
    _storage.put('permissions', null);

    notifyListeners();
  }

  Future<bool> setProjectAndGroup({String project, String group}) async {
    if (project == null || group == null) return false;

    _project = project;
    _group = group;
    var connected = await _http.isConnected();
    if (connected) {
      _http.setProjectAndGroup(project: project, group: group);
      await _getData();
    }

    if (_farmers == null) {
      _getData();
    }

    return true;
  }

  Future<void> _getData({int attempts: 1}) async {
    loading = true;
    try {
      //getting data from http
      var connected = await _http.isConnected();
      if (connected &&
          permissions != null &&
          _project != null &&
          _group != null) {
        ApiDataResponse dataResponse = await _http.getData();

        if( dataResponse.error == 'Permission deneid' &&
            attempts > 0){
          print(_userName);
          bool  success = await login(userName: _userName, password: _password);
          if(success) _getData(attempts: 0);
          return;
        }

        if (dataResponse.farmers != null) {
          dataResponse.farmers.forEach((farmerMap) {
            var farmer = Farmer.fromMap(farmerMap);
            _farmers[farmer.farmerId] = farmer;
          });

          _storage.put('farmers', dataResponse.farmers);
        }

        if (dataResponse.surveysQuestions != null) {
          dataResponse.surveysQuestions.forEach((surveysQuestionsMap) {
            var surveysQuestions = SurveysQuestion.fromMap(surveysQuestionsMap);
            _surveysQuestions[surveysQuestions.id] = surveysQuestions;
          });

          _storage.put('surveysQuestions', dataResponse.surveysQuestions);
        }

        if (dataResponse.surveys != null) {
          _surveys = {};
          dataResponse.surveys.forEach((surveyMap) {
            var survey = Survey.fromMap(surveyMap);
            _surveys.add(survey);
          });
          _storage.put('surveys', dataResponse.surveys);
        }


        if (dataResponse.notifications != null) {
          _notifications = [];
          dataResponse.notifications.forEach((notificationsMap) {
            var message = FdmsNotification.fromMap(notificationsMap);
            //print(message.toMap());
            _notifications.insert(0,message);
          });
          _storage.put('_notifications', dataResponse.notifications);
        }

        if (dataResponse.translations != null) {
          _translations = [];
          dataResponse.translations.forEach((translationMap) {
            var translation = Translation.fromMap(translationMap);
            _translations.add(translation);
          });

          _storage.put('translations', dataResponse.translations);
        }
      } else {
        _getDataFromStorage();
        Timer.periodic(new Duration(seconds: 5), (timer) async {
          if(_gotData) return;
          bool connected = await _http.isConnected();
          if (connected) {
            print('y');
            _getData();
            _gotData = true;
            notifyListeners();
            timer.cancel();
          }
        });
      }
    } catch (e) {
      print(e);
    }

    noData = _farmers.length == 0;
    loading = false;
    notifyListeners();
  }

  void _getDataFromStorage() {
    //getting data from local storage
    language = _storage.get('language');

    List<dynamic> farmersList = _storage.get('farmers');
    if (farmersList != null) {
      farmersList.forEach((farmerLinkedMap) {
        var farmer = Farmer.fromMap(_linkedMapToMap(farmerLinkedMap));
        _farmers[farmer.farmerId] = farmer;
      });
    }

    List<dynamic> surveysQuestionsList = _storage.get('surveysQuestions');
    if (surveysQuestionsList != null) {
      surveysQuestionsList.forEach((surveysQuestionLinkedMap) {
        var surveysQuestion =
            SurveysQuestion.fromMap(_linkedMapToMap(surveysQuestionLinkedMap));
        _surveysQuestions[surveysQuestion.id] = surveysQuestion;
      });
    }

    List<dynamic> surveysList = _storage.get('surveys');
    if (surveysList != null) {
      surveysList.forEach((surveyLinkedMap) {
        var survey = Survey.fromMap(_linkedMapToMap(surveyLinkedMap));
        _surveys.add(survey);
      });
    }

    List<dynamic> notificationsList = _storage.get('mesages');
    if (notificationsList != null) {
      notificationsList.forEach((messageLinkedMap) {
        var message = FdmsNotification.fromMap(_linkedMapToMap(messageLinkedMap));
        _notifications.add(message);
      });
    }

    List<dynamic> readNotificationsIdsList = _storage.get('readNotificationsIds');
    if (readNotificationsIdsList != null) {
      readNotificationsIdsList.forEach((messageId) {
        _readNotificationsIds.add(int.parse(messageId));
      });
    }

    List<dynamic> translationsList = _storage.get('translations');
    if (translationsList != null) {
      _translations = [];
      translationsList.forEach((translationLinkedMap) {
        var translation = Translation.fromMap(_linkedMapToMap(translationLinkedMap));
        _translations.add(translation);
      });
    }
  }

  String getTranslatedText(String text){
    if( _language == 'English' && text != 'Local') return text;
    Translation trans = _translations.firstWhere((t) => t.englishText == text, orElse: () => null);
    return trans == null ?
            text : trans.translation;
  }

  void saveForm(Map<String, dynamic> formData) async {
    loading = true;
    var connected = await _http.isConnected();
    if (connected) {
      try {
        var response = await _http.saveSurvey(formData);
        if (response == 'OK') dialogMessage = getTranslatedText('Survey saved');
      } catch (e) {
        print(e);
        _addToUnsaved(formData);
      }
    } else {
      _addToUnsaved(formData);
    }
    loading = false;
    notifyListeners();
  }

  void _addToUnsaved(formData) {
    dialogMessage = getTranslatedText('No connection, survey will be sent later');
    _unsentSurveys.add(formData);
    _storage.put('unsentSurveys', _unsentSurveys);
    if (_sendWhenConnectedTimer != null && !_sendWhenConnectedTimer.isActive)
      _sendWhenConnected();
  }

  void _sendWhenConnected() {
    _sendWhenConnectedTimer =
        Timer.periodic(new Duration(seconds: 5), (timer) async {
      bool connected = await _http.isConnected();
      print(connected);
      if (connected) {
        _unsentSurveys.forEach((surveyMap) async {
          try {
            var response = await _http.saveSurvey(surveyMap);
            if (response == 'OK') {
              _unsentSurveys.remove(surveyMap);
              _storage.put('unsentSurveys', _unsentSurveys);
            }
          } catch (e) {
            print(e);
          }
        });
        if (_unsentSurveys.length == 0) timer.cancel();
        notifyListeners();
      }
    });
  }

  Map<String, dynamic> _linkedMapToMap(dynamic linkedMap) {
    Map<String, dynamic> map = {};
    linkedMap.forEach((key, val) {
      map[key] = val;
    });
    return map;
  }
}
