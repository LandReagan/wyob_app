import 'package:flutter/material.dart';
import 'package:wyob/WyobException.dart';

import 'package:wyob/data/LocalDatabase.dart';
import 'package:wyob/widgets/DatabaseContentWidget.dart';
import 'package:wyob/widgets/IobFetchDialog.dart';
import 'package:wyob/widgets/IobStateWidget.dart';

class DatabasePage extends StatefulWidget {

  final LocalDatabase database = LocalDatabase();

  @override
  _DatabasePageState createState() => _DatabasePageState();
}

class _DatabasePageState extends State<DatabasePage> {

  bool _updating = false;

  @override
  void initState() {
    super.initState();
  }

  void _processData(Map<String, dynamic> data) async {
    setState(() {
      this._updating = true;
    });
    try {
      await widget.database.updateFromGantt(
          fromParameter: data['from'], toParameter: data['to']);
    } on WyobException { // We are probably Offline or IOB is down

    }
    setState(() {
      this._updating = false;
    });
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
      body: DatabaseByMonthWidget(widget.database),
      bottomNavigationBar: this._updating ? IobStateWidget(widget.database.connector) : null,
    );
  }
}
