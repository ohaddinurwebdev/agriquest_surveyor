import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../view/ProjectsList.dart';
import '../core/AppController.dart';
import 'TranslatedText.dart';
import 'LoginForm.dart';

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> {
  AppController _appController;

  bool _coverVisible = true;
  bool _coverExists  = true;
  bool _logoVisible = false;
  bool _showUserMenu = false;

  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 100), () {
      setState(() {
        _logoVisible = true;
      });
    });
    Timer(Duration(seconds: 5), () {
      setState(() {
        _coverVisible = false;
      });
      Timer(Duration(seconds: 1), () {
        setState(() {
          _coverExists = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _appController = Provider.of<AppController>(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Agriquest'),
                Text(
                  'Field Data Managment System',
                  style: TextStyle(fontSize: 10),
                )
              ],
            ),
            SizedBox(width: 3),
            Image.asset(
              'agriquest_white.png',
              height: 30,
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _appController.userName == null
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          InkWell(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.person,
                                      size: 22, color: Colors.grey),
                                  Text(_appController.userName,
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14))
                                ]),
                            onTap: () {
                              setState(() {
                                _showUserMenu = !_showUserMenu;
                              });
                            },
                          ),
                          _showUserMenu
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Language:'),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 20),
                                            child: InkWell(
                                              child: Text(
                                                'English',
                                                style: TextStyle(
                                                    color: _appController.language == 'English' ?
                                                    Colors.blueAccent :
                                                    Colors.black87,
                                                height: 1.8),
                                              ),
                                              onTap: () {
                                                _appController.language = 'English';
                                                setState(() {
                                                  _showUserMenu = false;
                                                });
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 20),
                                            child: InkWell(
                                              child: TranslatedText(
                                                'Local',
                                                style: TextStyle(
                                                    color: _appController.language == 'Local' ?
                                                    Colors.blueAccent :
                                                    Colors.black87,
                                                    height: 1.8),
                                              ),
                                              onTap: () {
                                                _appController.language = 'Local';
                                                setState(() {
                                                  _showUserMenu = false;
                                                });
                                              },
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Container(
                                            width: 80,
                                            decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(color: Colors.grey),
                                            )),
                                            child: InkWell(
                                              child: TranslatedText(
                                                'Logout',
                                                style: TextStyle(
                                                    color: Colors.redAccent,
                                                    height: 1.8),
                                              ),
                                              onTap: () {
                                                _appController.logout();
                                                setState(() {
                                                  _showUserMenu = false;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Container()
                        ],
                      ),
                    ),
              Expanded(
                child: Center(
                    child: _appController.userName == null ||
                            _appController.userName == '' ||
                            _appController.password == null ||
                            _appController.password == ''
                        ? LoginForm()
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 100),
                            child: _appController.permissions == null
                                ? TranslatedText(
                                    'No data available,\n please connect to the web to load data.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 18))
                                : ProjectsList())),
              ),
              _appController.unsavedCount > 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Text(
                                  _appController.unsavedCount.toString() + ' ',
                                  style:
                                      TextStyle(color: Colors.grey, fontSize: 14)),
                              TranslatedText('unsent surveys',
                                  style:
                                  TextStyle(color: Colors.grey, fontSize: 14))
                            ],
                          ),
                        ),
                      ],
                    )
                  : Container()
            ],
          ),
          Positioned.fill(
            child: _appController.loading
                ? Container(
                    color: Color(0xffcccccc).withOpacity(0.7),
                    child: Center(
                      child: CupertinoActivityIndicator(radius: 20),
                    ))
                : Container(),
          ),
          Positioned.fill(

              child: _coverExists ? AnimatedOpacity(
                opacity: _coverVisible ? 1.0 : 0.0,
                duration: Duration(seconds: 1),
                child: Container(
                color: Colors.white,
                    child:
                    AnimatedOpacity(
                    opacity: _logoVisible ? 1.0 : 0.0,
    duration: Duration(seconds: 3),
    child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'Agriquest.png', //'roundagon.png',
                            height: 140.0,
                            fit: BoxFit.cover,
                          ),
                          /*
                          SizedBox(height: 20),
                          Text(
                            'Agriquest',
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              color: Theme.of(context).backgroundColor,
                              fontFamily: 'Helvetica',
                              fontSize: 36,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                           */
                          SizedBox(height: 150),
                        ])))),
              ) : Container())
        ],
      ),
    );
  }
}
