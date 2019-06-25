import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

import 'package:wyob/data/LocalDatabase.dart';

enum RANK { CPT, FO, CD, CC }

class LoginPopUp extends StatefulWidget {

  final BuildContext context;

  LoginPopUp(this.context);

  _LoginPopUpState createState() => _LoginPopUpState();
}

class _LoginPopUpState extends State<LoginPopUp> {

  String username;
  String password;
  RANK rank;

  String rankString(RANK rank) {
    switch (rank) {
      case RANK.CPT: return "CPT"; break;
      case RANK.FO: return "FO"; break;
      case RANK.CD: return "CD"; break;
      case RANK.CC: return "CC / PGC"; break;
      default: return "";
    }
  }

  Future<void> updateDatabase() async {
    var database = LocalDatabase();
    await database.setCredentials(username, password, rankString(rank));
    await database.connect();
  }

  List<DropdownMenuItem> _getItems() {
    return RANK.values.map((rank) => DropdownMenuItem(value: rank, child: Text(rankString(rank)),)).toList();
  }

  void _changeRank(RANK value) {
    setState(() {
      rank = value;
    });
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
                  Text('Username:', textScaleFactor: 1.2,),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Staff Number',
                        hintStyle: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      textAlign: TextAlign.center,
                      onChanged: (String value) {
                        username = value;
                      },
                      keyboardType: TextInputType.number,
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  Text('Password:', textScaleFactor: 1.2,),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'IOB password',
                        hintStyle: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        password = value;
                      },
                      obscureText: true,
                    ),
                  )
                ],
              )
            ),
            Container(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  children: <Widget>[
                    Text('Rank:', textScaleFactor: 1.2,),
                    Expanded(
                      child: DropdownButton<RANK>(
                        items: _getItems(),
                        hint: Text('Choose one!', textAlign: TextAlign.center,),
                        value: rank,
                        onChanged: (value) => _changeRank(value),
                        isExpanded: true,
                      ),
                    )
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
