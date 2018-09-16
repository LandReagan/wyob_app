import 'package:flutter/material.dart';


class ContactScreen extends StatelessWidget {

  final Map<String, dynamic> details;

  ContactScreen(this.details);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(details['Name']),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.title),
            title: Text(details['Title']),
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text(details['Phone']),
          ),
          ListTile(
            leading: Icon(Icons.phone_android),
            title: Text(details['Mobile']),
          ),
          //TODO: Continue with the remaining fields
        ],
      ),
    );
  }
}