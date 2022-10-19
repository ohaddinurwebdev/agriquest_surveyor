import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/AppController.dart';
import 'TranslatedText.dart';

class LoginForm extends StatefulWidget {
  LoginForm({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<LoginForm> {
  AppController _appController;
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _showWelcomeText = true;

  @override
  Widget build(BuildContext context) {
    _appController = Provider.of<AppController>(context);
    if (_appController.userName != null)
      setState(() {
        _userNameController.text = _appController.userName;
      });

    return Container(
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _showWelcomeText
              ? Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: TranslatedText('Welcome, please login',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 18)),
                )
              : Container(),
          SizedBox(height: 25),
          CupertinoTextField(
              placeholder: 'User name',
              controller: _userNameController,
              onTap: () {
                setState(() {
                  _showWelcomeText = false;
                });
              }),
          SizedBox(height: 10),
          CupertinoTextField(
              placeholder: 'Password',
              controller: _passwordController,
              onTap: () {
                setState(() {
                  _showWelcomeText = false;
                });
              }),
          SizedBox(height: 10),
          _appController.loginError != null
              ? Text(_appController.loginError,
                  style: TextStyle(color: Colors.redAccent))
              : Container(),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'btn_login',
            onPressed: () async {
              if (_userNameController.text == '' ||
                  _passwordController.text == '') return;
              _appController.loginError = null;
              _appController.login(
                  userName: _userNameController.text,
                  password: _passwordController.text);
            },
            label: TranslatedText('LOGIN'),
            icon: const Icon(Icons.login_rounded),
          )
        ],
      ),
    );
  }
}
