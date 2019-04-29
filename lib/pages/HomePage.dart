import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wyob/WyobException.dart';
import 'package:wyob/data/LocalDatabase.dart';

// High level packages
import 'package:wyob/iob/IobConnector.dart';
import 'package:wyob/iob/IobDutyFactory.dart';

// Pages
import 'package:wyob/pages/UserSettingsPage.dart';
import 'package:wyob/pages/DirectoryPage.dart';
import 'package:wyob/pages/LoginPage.dart';
import 'package:wyob/pages/FtlMainPage.dart';

// Widgets
import 'package:wyob/widgets/DutiesWidget.dart';
import 'package:wyob/widgets/LoginPopUp.dart';

// Objects
import 'package:wyob/objects/Duty.dart';

// Utils
import 'package:wyob/utils/DateTimeUtils.dart';


class HomePage extends StatefulWidget {

  final LocalDatabase database = LocalDatabase();

  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {

  List<Duty> _duties = [];
  DateTime _lastUpdate;
  Timer _timer;

  bool updating = false;

  void initState() {
    super.initState();
    this._initialization();
    _timer = Timer.periodic(Duration(seconds: 1), resetPage);
  }

  void _initialization() async {
    try {
      await this.widget.database.connect();
    } on WyobExceptionCredentials catch (e) {
      showDialog(context: context, builder: (context) => LoginPopUp(context));
    }
    readDutiesFromDatabase();
    await updateFromIob();
  }

  void readDutiesFromDatabase() {

    setState(() {
      _duties = widget.database.getDuties(
          DateTime.now().subtract(Duration(days: 5)),
          DateTime.now().add(Duration(days: 30))
      );
      _lastUpdate = widget.database.updateTimeLoc;
    });
  }

  Future<void> updateFromIob() async {

    setState(() {
      updating = true;
    });

    try {
      await widget.database.updateFromGantt();
    } on WyobExceptionCredentials catch (e) {
      print('Credentials not in database');
    } on WyobExceptionOffline catch (e) {
      print('OFFLINE MODE.');
    } on Exception catch (e) {
      print('Unhandled exception caught: ' + e.toString());
    }

    readDutiesFromDatabase();

    setState(() {
      updating = false;
    });
  }

  String getSinceLastUpdateMessage() {
    if (_lastUpdate != null) {
      Duration sinceLastUpdate = DateTime.now().difference(_lastUpdate);
      int hours = sinceLastUpdate.inHours;
      sinceLastUpdate -= Duration(hours: sinceLastUpdate.inHours);
      int minutes = sinceLastUpdate.inMinutes;
      return "LAST UPDATE: " + _lastUpdate.toString().substring(0, 16) + '\n' +
        hours.toString() + ' hours and ' + minutes.toString() + ' minutes ago';
    } else {
      return "---";
    }
  }

  void resetPage(Timer timer) {
    setState(() {

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
                      title: Text("Login credentials")
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        )
                    );
                  },
                ),
                new GestureDetector(
                  child: ListTile(
                      contentPadding: EdgeInsets.all(10.0),
                      leading: Icon(Icons.access_time),
                      title: Text("FTL Calculator")
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FtlMainPage(),
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
              FlatButton(
                child: updating ? CircularProgressIndicator() : Text('UPDATE'),
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
