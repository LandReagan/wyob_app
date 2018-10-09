import 'package:flutter/material.dart';


class LoginPage extends StatefulWidget {

  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("IOB login:"),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              hintText: 'Username (Staff number)',
            ),
          ),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Password',
            ),
          )
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