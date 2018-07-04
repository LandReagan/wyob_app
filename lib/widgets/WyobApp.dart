import 'dart:convert';

import 'package:flutter/material.dart';

import 'DutiesWidget.dart';
import '../Duty.dart' show Duty;
import '../FileManager.dart';
import '../IobConnect.dart';
import '../IobDutyFactory.dart';


class WyobApp extends StatefulWidget {
  WyobAppState createState() => new WyobAppState();
}
class WyobAppState extends State<WyobApp> {

  List<Duty> duties = [];

  void initState() {
    super.initState();
    readDutiesFromDatabase();
  }

  void readDutiesFromDatabase() async {
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
        drawer: new Drawer(),
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
