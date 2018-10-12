import 'package:flutter/material.dart';


class LoginPage extends StatefulWidget {

  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  String _staffNumber;
  String _password;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitCredentials() {
    if (_staffNumber != null && _password != null) {
      // TODO: set the data in the user's data...
    }

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
          /*
          Row(
            children: <Widget>[
              Text("User name:"),
              TextField(
                decoration: InputDecoration(
                  hintText: '(Staff number)',
                ),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Text('Password:'),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '(Staff number)',
                ),
              )
            ],
          )
          */
        ],
      ),
    );
  }
}