import 'package:http/http.dart' as http;
import 'dart:convert';
//web
//import 'dart:html';

//Android / IOS
import 'package:data_connection_checker/data_connection_checker.dart';

import '../data/ApiDataResponse.dart';

class Http {
  String _controllerUrl;

  Http(String baseUrl){
    _controllerUrl = baseUrl + 'fdms-app-controller.php';
  }

  Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8'
  };

  String _userName;
  String _sessionToken;
  String _project;
  String _group;

  Future<Map<String, dynamic>> login({String userName, String password}) async {
    try {
      final Map<String, dynamic> response = await post(
          {"action": "login", "userName": userName, "password": password});

      if (response['status'] == 'OK') {
        _userName = userName;
        _sessionToken = response['sessionToken'];
        return response;
      } else {
        throw (response['error']);
      }
    } catch (e) {
      print('http error');
      print(e);
      return {'error': e.toString()};
    }
  }

  void setProjectAndGroup({String project, String group}) {
    _project = project;
    _group = group;
  }

  Future<ApiDataResponse> getData() async {
    try {
      final Map<String, dynamic> response = await post(
        {'action': 'get-data'},
      );

      if (response['status'] == 'OK') {
        return ApiDataResponse(
            farmers: response['farmers'],
            surveysQuestions: response['surveysQuestions'],
            surveys: response['surveys'],
            notifications: response['notifications'],
            translations: response['translations']);
      } else {
        throw (response['error']);
      }
    } catch (e) {
      print('http error');
      print(e);
      return ApiDataResponse(error: e.toString());
    }
  }

  Future<String> saveSurvey(Map<String, dynamic> surveyMap) async {
    try {
      final Map<String, dynamic> response = await post(
        {"action": "save-survey", "data": surveyMap},
      );

      if (response['status'] == 'OK') {
        return 'OK';
      } else {
        throw response['error'];
      }
    } catch (e) {
      print('http error');
      print(e);
      return e.toString();
    }
  }

  Future<Map<String, dynamic>> post(Map<String, dynamic> data) async {
    try {
      if (data['action'] != 'login') {
        data['userName'] = _userName;
        data['sessionToken'] = _sessionToken;
        data['project'] = _project;
        data['group'] = _group;
      }
      String dataJSON = jsonEncode(data);
      //print(dataJSON);
      http.Response response = await http.post(Uri.parse(_controllerUrl),
          body: dataJSON, headers: _headers);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // If the server did return a 201 CREATED response,
        // then parse the JSON.
        //updateCookie(response);
        //print(response.body);
        return jsonDecode(response.body);
      } else {
        // If the server did not return a 201 CREATED response,
        // then throw an exception.
        throw Exception('Failed to load data.');
      }
    } catch (e) {
      print('http error');
      print(e);
      return {'status': 'error', 'error': e.toString()};
    }
  }

  /*
  void updateCookie(http.Response response) {
    print(response.headers);
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }
   */

  Future<bool> isConnected() async {
    //Android / IOS
    bool result = await DataConnectionChecker().hasConnection;

    //Web
    //bool result = window.navigator.onLine;
    return result;
  }
}
