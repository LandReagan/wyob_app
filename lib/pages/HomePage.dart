import 'dart:convert';

import 'package:flutter/material.dart';

// High level packages
import 'package:wyob/data/Database.dart';
import 'package:wyob/data/FileManager.dart';
import 'package:wyob/iob/IobConnect.dart';
import 'package:wyob/iob/IobDutyFactory.dart';

// Pages
import 'package:wyob/pages/UserSettingsPage.dart';
import 'package:wyob/pages/DirectoryPage.dart';
import 'package:wyob/pages/LoginPage.dart';

// Widgets
import 'package:wyob/widgets/DutiesWidget.dart';

// Objects
import 'package:wyob/objects/Duty.dart';
import 'package:wyob/objects/DutyData.dart';

// Utils
import 'package:wyob/utils/DateTimeUtils.dart';


class HomePage extends StatefulWidget {
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {

  List<Duty> _duties = [];
  DateTime _lastUpdate;
  bool updating = false;

  void initState() {
    super.initState();
    this._initialization();
  }

  void _initialization() async {
    // 1. Check for user credentials:
    Map<String, dynamic> userData = json.decode(
        await FileManager.readUserData());
    if (!userData.containsKey('username') || userData['username'] == '') {
      Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => LoginPage()
        )
      );
    }
    await readDutiesFromDatabase();
    await updateFromIob();
  }

  Future<void> readDutiesFromDatabase() async {

    DutyData dutyData = await Database.getDutiesReduced();

    setState(() {
      _duties = dutyData.duties;
      _lastUpdate = dutyData.lastUpdate?.loc;
    });
  }

  Future<void> updateFromIob() async {

    setState(() {
      updating = true;
    });

    //TODO: Check for online status first!
    Map<String, dynamic> userData = json.decode(await FileManager.readUserData());
    IobConnector connector = IobConnector(userData['username'], userData['password']);
    String checkInListText = await connector.run();

    // In the case of a failure...
    if (checkInListText == "")
      return;

    List<Duty> newDuties = IobDutyFactory.run(checkInListText);

    // In the case of a failure...
    if (newDuties.isEmpty)
      return;

    // TODO: Get UTC difference from system
    AwareDT now = AwareDT.fromDateTimes(DateTime.now(), DateTime.now().toUtc());

    await Database.updateDuties(now, newDuties);

    readDutiesFromDatabase();

    setState(() {
      updating = false;
    });
  }

  String getSinceLastUpdateMessage() {
    if (_lastUpdate != null) {
      Duration sinceLastUpdate = DateTime.now().difference(_lastUpdate);
      //return sinceLastUpdate.inMinutes.toString();
      return "LAST UPDATE: " + _lastUpdate.toString().substring(0, 16);
    } else {
      return "---";
    }
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
                /* Directory
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
                ),
                */
                new GestureDetector(
                  child: ListTile(
                      contentPadding: EdgeInsets.all(10.0),
                      leading: Icon(Icons.lock_outline),
                      title: Text("Login")
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        )
                    );
                  },
                )
              ],
            )
        ),
        appBar: new AppBar(
          title: new Text("WYOB v0.1 alpha"),
        ),
        body: new HomeWidget(_duties),
        bottomNavigationBar: BottomAppBar(
          color: Colors.orange,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(getSinceLastUpdateMessage(), textAlign: TextAlign.center,),
              ),
              IconButton(
                icon: updating ? CircularProgressIndicator() : Icon(Icons.system_update),
                onPressed: updateFromIob,
              ),
            ],
          ),
        ),
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
        new Container(
            child: Text("Duties:")
        ),
        new DutiesWidget(duties),
      ],
    );
  }
}
