import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wyob/WyobException.dart';
import 'package:wyob/data/LocalDatabase.dart';

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
  DateTime _lastUpdate;

  void initState() {
    super.initState();
    this._initialization();
  }

  void _initialization() async {
    try {
      await widget.database.connect();
      readDutiesFromDatabase();
      await updateFromIob();
    } on WyobExceptionCredentials {
      await showDialog(context: context, builder: (context) => LoginPopUp(context));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void readDutiesFromDatabase() {
    setState(() {
      _duties = widget.database.getDuties(
          DateTime.now().subtract(Duration(days: 3)),
          DateTime.now().add(Duration(days: 40)));
      _lastUpdate = widget.database.updateTimeLoc;
    });
  }

  Future<void> updateFromIob() async {

    try {
      await widget.database.updateFromGantt();
    } on WyobExceptionCredentials {
      print('Credentials not in database');
    } on WyobExceptionOffline {
      print('OFFLINE MODE.');
    } on Exception catch (e) {
      print('Unhandled exception caught: ' + e.toString());
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
                  ).then((value) => this.setState(() {}));
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
          title: Text("WYOB v0.2 beta"),
        ),
        body: HomeWidget(_duties),
        bottomNavigationBar: BottomAppBar(
          color: Colors.orange,
          child: IobStateWidget(widget.database.connector),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DutiesWidget(duties),
      ],
    );
  }
}
