import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/AppController.dart';
import 'NotificationViewer.dart';
import 'TranslatedText.dart';

import '../data/Notification.dart';

class NotificationsList extends StatelessWidget {
  AppController _appController;
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    _appController = Provider.of<AppController>(context);
    return Scaffold(
        appBar: AppBar(
          title: TranslatedText('Notifications'),
        ),
        body: Container(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 10),
                        for (FdmsNotification notification
                            in _appController.notifications)
                          InkWell(
                            onTap: (){
                              _appController.setNotificationAsRead(notification.id);
                                Navigator.push(
                                  context,
                                    MaterialPageRoute(
                                    builder: (context) =>
                                        NotificationViewer(notification)),
                                  );
                                },
                            child: Container(
                                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: _appController.notificationIsRead(notification.id) ?
                                  Colors.grey.shade200 : Colors.transparent,
                                  border: Border(
                                    bottom: BorderSide(width: 1, color: Colors.grey.shade400)),
                                ),
                                child: Row(
                                  children: [
                                    Text(formatter.format(notification.timestamp),
                                        style: TextStyle(color: Colors.black87, fontSize: 14)),
                                    SizedBox(width: 10,),
                                    Expanded(child: Text(notification.title,
                                    style: TextStyle(color: Colors.black87, fontSize: 14))),
                                    SizedBox(width: 20,),
                                    notification.photos != null && notification.photos != '' ?
                                        Icon(Icons.photo_outlined,
                                            size: 20,
                                        color: Colors.black87,) : Container()
                                  ],
                                )),
                          )
                      ]),
                ),
              ),
            ),
    );
  }
}
