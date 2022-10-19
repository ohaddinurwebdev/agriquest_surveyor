import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../core/AppController.dart';
import 'TranslatedText.dart';

import 'SurveyPicker.dart';

class ProjectsList extends StatelessWidget {
  AppController _appController;

  @override
  Widget build(BuildContext context) {
    _appController = Provider.of<AppController>(context);
    return _appController.permissions == null
        ? Container()
        : Container(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TranslatedText('Pick a group:',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                      SizedBox(
                        height: 10,
                      ),
                      for (var project
                          in _appController.permissions.projects.entries)
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    width: 1, color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        project.key,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,),
                                      ),
                                      Expanded(child: Container())
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Wrap(
                                        spacing: 15,
                                        runSpacing: 15,
                                        children: [
                                          for (var group
                                              in project.value.groups)
                                            InkWell(
                                              child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xfff1f1f1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Colors
                                                            .grey.shade300),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.3),
                                                        spreadRadius: 1,
                                                        blurRadius: 2,
                                                        offset: Offset(1,
                                                            1), // changes position of shadow
                                                      ),
                                                    ],
                                                  ),
                                                  child: Text(group.groupName,
                                                      style: TextStyle(
                                                          color:
                                                              Colors.blueAccent,
                                                          fontSize: 12))),
                                              onTap: () async {
                                                bool success =
                                                    await _appController
                                                        .setProjectAndGroup(
                                                            project:
                                                                project.key,
                                                            group: group
                                                                .groupName);
                                                if (success)
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            SurveyPicker()),
                                                  );
                                              },
                                            )
                                        ]),
                                  ),
                                ],
                              )),
                        )
                    ]),
              ),
            ),
          );
  }
}
