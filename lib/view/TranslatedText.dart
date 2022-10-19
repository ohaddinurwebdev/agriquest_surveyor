import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/AppController.dart';

class TranslatedText extends StatelessWidget {
  String text;
  TextAlign textAlign;
  TextStyle style;
  TranslatedText(this.text,{ this.textAlign, this.style, Key key }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    AppController _appController = Provider.of<AppController>(context);
    return Text(_appController.getTranslatedText(text),
    textAlign: textAlign,
    style: style,);
  }
}