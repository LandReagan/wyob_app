import 'package:flutter/material.dart';


class HomePageBottomBar extends StatelessWidget {

  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        children: <Widget>[
          Icon(Icons.autorenew),
        ],
      ),
    );
  }
}