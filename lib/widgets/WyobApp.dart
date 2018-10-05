import 'dart:async';

import 'package:flutter/material.dart';

import 'DutiesWidget.dart';
import 'DirectoryPage.dart';
import 'UserSettingsPage.dart';
import 'package:wyob/objects/Duty.dart' show Duty;
import 'package:wyob/objects/DutyData.dart' show DutyData;
import '../IobConnect.dart';
import '../IobDutyFactory.dart';
import '../Database.dart' show Database;
import '../utils/DateTimeUtils.dart' show AwareDT;


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

  List<Duty> _duties = [];
  DateTime _lastUpdate;
  Timer _timer;

  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    await readDutiesFromDatabase();
    await updateFromIob();
  }

  Future<void> readDutiesFromDatabase() async {

    List<Duty> duties = (await Database.getDuties()).duties;

    setState(() {
      _duties = duties;
    });
  }

  Future<void> updateFromIob() async {

    //TODO: Check for online status first!

    String checkInListText = await IobConnect.run('93429', '93429');

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
    DutyData dutyData = await Database.getDutiesReduced();

    setState(() {
      _duties = dutyData.duties;
      _lastUpdate = dutyData.lastUpdate.loc;
    });
  }

  String getSinceLastUpdateMessage() {
    if (_lastUpdate != null) {
      Duration sinceLastUpdate = DateTime.now().difference(_lastUpdate);
      //return sinceLastUpdate.inMinutes.toString();
      return "LAST UPDATE: " + _lastUpdate.toString().substring(0, 16);
    } else {
      return "?";
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
                icon: Icon(Icons.system_update),
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
        new DutiesWidget(duties),
      ],
    );
  }
}
