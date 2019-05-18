import 'package:flutter/material.dart';

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
    this._updating = true;
    await widget.database.updateFromGantt(
        fromParameter: data['from'], toParameter: data['to']);
    this._updating = false;
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
      body: DatabaseContentWidget(widget.database.getDutiesAll()),
      bottomNavigationBar: this._updating ? IobStateWidget(this.widget.database) : null,
    );
  }
}
