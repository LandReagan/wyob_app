import 'package:flutter/material.dart';
import 'package:wyob/WyobException.dart';

import 'package:wyob/data/LocalDatabase.dart';
import 'package:wyob/widgets/DatabaseContentWidget.dart';
import 'package:wyob/widgets/IobFetchDialog.dart';
import 'package:wyob/widgets/IobStateWidget.dart';

class DatabasePage extends StatefulWidget {

  @override
  _DatabasePageState createState() => _DatabasePageState();
}

class _DatabasePageState extends State<DatabasePage> {

  LocalDatabase database;

  @override
  void initState() {
    super.initState();
    database = LocalDatabase();
  }

  void _processData(Map<String, dynamic> data) async {
    try {
      await database.updateFromGantt(
          fromParameter: data['from'], toParameter: data['to']);
      setState(() {
        database = LocalDatabase();
      }); // Just to rebuild the page and get the new duties
    } on WyobException {
      // We are probably Offline or IOB is down. Shall we do something?
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Database'),
        actions: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            child: OutlineButton(
              child: Text('Fetch'),
              textColor: Colors.white,
              borderSide: BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
              onPressed: () async {
                Map<String, dynamic> data = await showDialog(
                  context: context,
                  builder: (context) {
                    return IobFetchDialog();
                  }
                );
                this._processData(data);
              },
            ),
          ),
        ],
      ),
      body: DatabaseByMonthWidget(database),
      bottomNavigationBar: IobStateWidget(database, null),
    );
  }
}
