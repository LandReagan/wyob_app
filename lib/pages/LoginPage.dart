import 'dart:convert';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {

  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String _staffNumber;
  String _password;

  void _submitCredentials() async {
    // todo: link with database and set in.
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("IOB login:"),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Username (Staff number)',
            ),
            onChanged: (String staffNumberValue) {
              _staffNumber = staffNumberValue;
            },
          ),
          TextField(
            textAlign: TextAlign.center,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Password',
            ),
            onChanged: (String passwordValue) {
              _password = passwordValue;
            },
            onSubmitted: (String passwordValue) {
              _submitCredentials();
            },
          ),
        ],
      ),
    );
  }
}
