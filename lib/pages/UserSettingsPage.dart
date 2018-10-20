import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wyob/data/FileManager.dart';


class UserSettingsPage extends StatefulWidget {
  UserSettingsPageState createState() => UserSettingsPageState();
}

class UserSettingsPageState extends State<UserSettingsPage> {

  Map<String, dynamic> userData;

  UserSettingsPageState() {
    loadUserData();
  }

  void loadUserData() async {
    Map<String, dynamic> data = json.decode(await FileManager.readUserData());
    setState(() {
      userData = data;
    });
  }

  // TODO Define what data is needed
  // TODO implement a method to change data

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          child: Icon(Icons.arrow_back),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        title: Text("User settings"),
      ),
      body: ListView.builder(
        itemCount: userData == null ? 0 : userData.length,
        itemBuilder: (context, index) {
          return Row(
            children: <Widget>[
              Container(
                child: Text(userData.keys.elementAt(index)),
              ),
              Expanded(
                child: Text(userData.values.elementAt(index)),
              )
            ],
          );
        },
      ),
    );
  }
}