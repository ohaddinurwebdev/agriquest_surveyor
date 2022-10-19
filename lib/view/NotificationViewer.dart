import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/AppController.dart';
import 'TranslatedText.dart';

import '../data/Notification.dart';

class NotificationViewer extends StatelessWidget {
  FdmsNotification notification;
  AppController _appController;
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  NotificationViewer(this.notification, {key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    _appController = Provider.of<AppController>(context);
    return Scaffold(
        appBar: AppBar(
          title: TranslatedText(notification.title),
        ),
        body: Container(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(formatter.format(notification.timestamp),
                                style: TextStyle(color: Colors.black87, fontSize: 14)),
                              ]),
                        SizedBox(height: 10),
                         Text(notification.message,
                            style: TextStyle(color: Colors.black87, fontSize: 14)),
                        SizedBox(height: 10),
                        notification.photos != null && notification.photos != '' ?
                        Image.network((_appController.baseUrl +
                                      'images/' +
                                      notification.photos).replaceAll(' ', '%20')) :
                            Container()
                            ],),
                ),
              ),
            ),
    );
  }
}
