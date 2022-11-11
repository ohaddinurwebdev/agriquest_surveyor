import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'core/AppController.dart';
import 'view/Home.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    AppController appController = AppController();
    appController.initApp();
    return ChangeNotifierProvider<AppController>(
      create: (context) => appController,
      child: MaterialApp(
        title: 'Agriquest - Surveyor',
        theme: ThemeData(
          primarySwatch: Colors.green,
          textTheme: TextTheme(
            bodyText1: TextStyle(fontSize: 16)
          )
        ),
        home: Home(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}


