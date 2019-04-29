import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:wyob/data/LocalDatabase.dart';

class LoginPopUp extends StatefulWidget {

  final BuildContext context;

  LoginPopUp(this.context);

  _LoginPopUpState createState() => _LoginPopUpState();
}

class _LoginPopUpState extends State<LoginPopUp> {

  String username;
  String password;

  Future<void> updateDatabase() async {
    var database = LocalDatabase();
    await database.setCredentials(username, password);
  }

  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('IOB Login:', textAlign: TextAlign.center,),
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  Text('Username: (Staff number)'),
                  Expanded(child: TextField(
                    onChanged: (value) {
                      username = value;
                    },
                  ),)
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  Text('Password:'),
                  Expanded(child: TextField(
                    onChanged: (value) {
                      password = value;
                    },
                  ),)
                ],
              )
            )
          ],
        ),
        Row(
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context); },
              child: Text('CANCEL'),
            ),
            Spacer(),
            SimpleDialogOption(
              onPressed: () {
                updateDatabase();
                Navigator.pop(context);
              },
              child: Text('VALIDATE'),
            )
          ],
        )
      ],
    );
  }
}
