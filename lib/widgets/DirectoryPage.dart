import 'package:flutter/material.dart';


class DirectoryPage extends StatelessWidget {

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          child: Icon(Icons.arrow_back),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        title: new Text("WY Directory"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.phone),
            title: Text("SMLO" + ": " + "99 99 99 99"),
            subtitle: Text("Abdul Rahman Al Balushi"),
          )
        ],
      ),
    );
  }
}