import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wyob/WyobException.dart';
import 'package:wyob/data/LocalDatabase.dart';
import 'package:wyob/iob/IobConnector.dart';

import 'package:wyob/pages/DatabasePage.dart';
import 'package:wyob/pages/FtlMainPage.dart';

// Widgets
import 'package:wyob/widgets/DutiesWidget.dart';
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

  bool updating = false;
  CONNECTOR_STATUS _connectorStatus = CONNECTOR_STATUS.OFF;

  void initState() {
    super.initState();
    this._initialization();
    Timer.periodic(Duration(seconds: 30), resetPage);
  }

  void _initialization() async {
    try {
      await widget.database.connect();
      widget.database.connector.onStatusChanged
          .addListener(_handleConnectorStatusChange);
    } on WyobExceptionCredentials {
      showDialog(context: context, builder: (context) => LoginPopUp(context));
      return;
    }
    readDutiesFromDatabase();
    await updateFromIob();
  }

  @override
  void dispose() {
    widget.database.connector.onStatusChanged
        .removeListener(this._handleConnectorStatusChange);
    super.dispose();
  }

  void _handleConnectorStatusChange() {
    setState(() {
      this._connectorStatus = widget.database.connector.status;
    });
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
    setState(() {
      updating = true;
    });

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

    setState(() {
      updating = false;
    });
  }

  String _getSinceLastUpdateMessage() {
    if (_lastUpdate != null) {
      Duration sinceLastUpdate = DateTime.now().difference(_lastUpdate);
      int hours = sinceLastUpdate.inHours;
      sinceLastUpdate -= Duration(hours: sinceLastUpdate.inHours);
      int minutes = sinceLastUpdate.inMinutes;
      return "LAST UPDATE: " +
          _lastUpdate.toString().substring(0, 16) +
          '\n' +
          hours.toString() +
          ' hours and ' +
          minutes.toString() +
          ' minutes ago';
    } else {
      return "---";
    }
  }

  void resetPage(Timer timer) {
    setState(() {});
  }

  Widget _getUpdateWidget() {
    switch (_connectorStatus) {
      case CONNECTOR_STATUS.OFF:
        return Row(
          children: <Widget>[
            Expanded(
              child: Text(
                _getSinceLastUpdateMessage(),
                textAlign: TextAlign.center,
              ),
            ),
            FlatButton(
              child: Text('UPDATE'),
              onPressed: updateFromIob,
            ),
          ],
        );
        break;

      case CONNECTOR_STATUS.CONNECTING:
        return Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'CONNECTING',
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: EdgeInsets.all(5.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
          ],
        );
        break;

      case CONNECTOR_STATUS.CONNECTED:
        return Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'CONNECTED',
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              child: Text(' \n'),
              padding: EdgeInsets.all(5.0),
            )
          ],
        );
        break;

      case CONNECTOR_STATUS.AUTHENTIFIED:
        return Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'AUTHENTIFIED',
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              child: Text(' \n'),
              padding: EdgeInsets.all(5.0),
            )
          ],
        );
        break;

      case CONNECTOR_STATUS.FETCHING_GANTT_TABLE:
        return Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'FETCHING GANTT TABLE',
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: EdgeInsets.all(5.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
          ],
        );
        break;

      case CONNECTOR_STATUS.FETCHING_DUTIES:
        return Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'FETCHING GANTT DUTIES',
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: EdgeInsets.all(5.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
          ],
        );
        break;

      case CONNECTOR_STATUS.OFFLINE:
        return Row(
          children: <Widget>[
            Expanded(
              child: Text(
                _getSinceLastUpdateMessage(),
                textAlign: TextAlign.center,
              ),
            ),
            FlatButton(
              child: Text('UPDATE'),
              onPressed: updateFromIob,
            ),
          ],
        );
        break;

      case CONNECTOR_STATUS.LOGIN_FAILED:
        return Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'LOGIN TO IOB FAILED!',
                textAlign: TextAlign.center,
              ),
            ),
            FlatButton(
                child: Text('LOGIN'),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => LoginPopUp(context));
                }),
          ],
        );
        break;

      case CONNECTOR_STATUS.ERROR:
        return Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'ERROR!',
                textAlign: TextAlign.center,
              ),
            ),
            FlatButton(
              child: Text('RETRY'),
              onPressed: updateFromIob,
            ),
          ],
        );
        break;

      default:
        return Row(
          children: <Widget>[
            Expanded(
              child: Text(
                _getSinceLastUpdateMessage(),
                textAlign: TextAlign.center,
              ),
            ),
            FlatButton(
              child: Text('UPDATE'),
              onPressed: updateFromIob,
            ),
          ],
        );
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
          child: _getUpdateWidget(),
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
