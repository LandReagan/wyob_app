import 'dart:convert';

import 'package:flutter/material.dart';

import 'DutiesWidget.dart';
import 'DirectoryPage.dart';
import 'UserSettingsPage.dart';
import '../Duty.dart' show Duty;
import '../FileManager.dart';
import '../IobConnect.dart';
import '../IobDutyFactory.dart';


class WyobApp extends StatelessWidget {

  Widget build(BuildContext context) {
    return MaterialApp(
      home: WyobAppHome(),
    );
  }
}

class WyobAppHome extends StatefulWidget {
  WyobAppHomeState createState() => new WyobAppHomeState();
}

class WyobAppHomeState extends State<WyobAppHome> {

  List<Duty> duties = [];

  void initState() {
    super.initState();
    //updateFromIob();
    readDutiesFromDatabase();
  }

  void readDutiesFromDatabase() async {
    print("Reading from database...");
    String jsonDuties = await FileManager.readCurrentDuties();
    setState(() {
      if (jsonDuties != "") {
        Map<String, dynamic> dutyObjects = json.decode(jsonDuties);
        dutyObjects.forEach((index, dutyObject) {
          duties.add(new Duty.fromMap(dutyObject));
        });
      }
    });
  }

  void updateFromIob() async {

    //TODO: Check for online status first!

    String checkinListText = await IobConnect.run('93429', '93429');
    var jsonDuties = new Map<String, dynamic>();
    for (var i = 0; i < duties.length; i++) {
      jsonDuties[i.toString()] = duties[i].toMap();
    }
    FileManager.writeCurrentDuties(json.encode(jsonDuties));
    setState(() {
      duties = IobDutyFactory.run(checkinListText);
    });
  }


  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'WYOB',
      home: new Scaffold(
        drawer: new Drawer(
          child: new ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              new DrawerHeader(
                //TODO Harmonize style
                child: new Text("Menu", style: TextStyle(fontSize: 20.0)),
              ),
              new GestureDetector(
                child: ListTile(
                    contentPadding: EdgeInsets.all(10.0),
                    leading: Icon(Icons.insert_emoticon),
                    title: Text("User")
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserSettingsPage(),
                    )
                  );
                },
              ),
              new GestureDetector(
                child: ListTile(
                  contentPadding: EdgeInsets.all(10.0),
                  leading: Icon(Icons.phone),
                  title: Text("Directory")
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DirectoryPage(),
                    )
                  );
                },
              )
            ],
          )
        ),
        appBar: new AppBar(
          title: new Text("WYOB v0.1 alpha"),
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.autorenew),
                onPressed: updateFromIob,
            )
          ],
        ),
        body: new HomeWidget(duties),
      ),
    );
  }
}

class HomeWidget extends StatelessWidget {

  final List<Duty> duties;

  HomeWidget(this.duties);

  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new DutiesWidget(duties),
      ],
    );
  }
}
