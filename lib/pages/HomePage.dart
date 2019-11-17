import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:logger_flutter/logger_flutter.dart';
import 'package:wyob/WyobException.dart';
import 'package:wyob/data/LocalDatabase.dart';
import 'package:wyob/objects/Statistics.dart';

import 'package:wyob/pages/DatabasePage.dart';
import 'package:wyob/pages/FtlMainPage.dart';

// Widgets
import 'package:wyob/widgets/DutiesWidget.dart';
import 'package:wyob/widgets/IobStateWidget.dart';
import 'package:wyob/widgets/LoginPopUp.dart';

// Objects
import 'package:wyob/objects/Duty.dart';

class HomePage extends StatefulWidget {
  final LocalDatabase database = LocalDatabase();

  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Duty> _duties = [];
  List<Statistics> _statistics = [];
  DateTime _lastUpdate;

  void initState() {
    super.initState();
    var logger = Logger();
    logger.d("Logger starts...");
    this._initialization();
  }

  void _initialization() async {
    try {
      await widget.database.connect();
      readDutiesFromDatabase();
      await updateFromIob();
    } on WyobExceptionCredentials {
      await showDialog(context: context, builder: (context) => LoginPopUp(context));
    } on Exception {
      Logger().e("Unexpected error on accessing File System!");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void refresh() {
    setState(() {
      readDutiesFromDatabase();
    });
  }

  void readDutiesFromDatabase() {
    setState(() {
      _duties = widget.database.getDuties(
          DateTime.now().subtract(Duration(days: 3)),
          DateTime.now().add(Duration(days: 40)));
      _lastUpdate = widget.database.updateTimeLoc;
      _statistics = widget.database.statistics;
    });
  }

  Future<void> updateFromIob() async {

    try {
      await widget.database.updateFromGantt();
    } on WyobExceptionCredentials {
      Logger().w('Credentials not in database');
    } on WyobExceptionOffline {
      Logger().i('OFFLINE MODE.');
    } on Exception catch (e) {
      Logger().e('Unhandled exception caught: ' + e.toString());
    }

    readDutiesFromDatabase();

    setState(() {});
  }

  String _getSinceLastUpdateMessage() {
    if (_lastUpdate != null) {
      return "LAST UPDATE: " + _lastUpdate.toString().substring(0, 16);
    } else {
      return "PLEASE UPDATE!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WYOB',
      home: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text("Menu", style: TextStyle(fontSize: 20.0)),
              ),
              GestureDetector(
                child: ListTile(
                    contentPadding: EdgeInsets.all(10.0),
                    leading: Icon(Icons.lock_outline),
                    title: Text("Login credentials")),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return LoginPopUp(context);
                    }
                  );
                },
              ),
              GestureDetector(
                child: ListTile(
                    contentPadding: EdgeInsets.all(10.0),
                    leading: Icon(Icons.keyboard),
                    title: Text("Database")),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DatabasePage(),
                    )
                  ).then((value) => this.readDutiesFromDatabase());
                },
              ),
              GestureDetector(
                child: ListTile(
                    contentPadding: EdgeInsets.all(10.0),
                    leading: Icon(Icons.av_timer),
                    title: Text("FTL Calculator")),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FtlMainPage(null, null),
                    )
                  );
                },
              ),
            ],
          )
        ),
        appBar: AppBar(
          title: Text("WYOB v0.3.3 beta"),
        ),
        body: LogConsoleOnShake(
          child: HomeWidget(_duties, _statistics),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.orange,
          child: IobStateWidget(widget.database, refresh),
        ),
      ),
    );
  }
}

class HomeWidget extends StatelessWidget {
  final List<Duty> duties;
  final List<Statistics> statistics;

  HomeWidget(this.duties, this.statistics);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DutiesWidget(duties, statistics),
      ],
    );
  }
}
