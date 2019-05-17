import 'package:flutter/material.dart';

import 'package:wyob/data/LocalDatabase.dart';
import 'package:wyob/iob/IobConnector.dart';
import 'package:wyob/widgets/DatabaseContentWidget.dart';
import 'package:wyob/widgets/IobFetchDialog.dart';

class DatabasePage extends StatefulWidget {

  final LocalDatabase database = LocalDatabase();

  @override
  _DatabasePageState createState() => _DatabasePageState();
}

class _DatabasePageState extends State<DatabasePage> {

  bool _updating = false;
  ValueChanged<CONNECTOR_STATUS> onConnectorStatusChanged;

  @override
  void initState() {
    super.initState();
    onConnectorStatusChanged = widget.database.onConnectorStatusChanged;
  }

  void _fetchData(DateTime from, DateTime to) async {
    setState(() {
      _updating = true;
    });

    await widget.database.updateFromGantt(fromParameter: from, toParameter: to);

    setState(() {
      _updating = false;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Database'),
        /*
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
                _fetchData(data['from'], data['to']);
              },
            ),
          ),
        ],
        */
      ),
      body: DatabaseContentWidget(widget.database.getDutiesAll()),
      bottomNavigationBar: this._updating ? null : null,
    );
  }
}
