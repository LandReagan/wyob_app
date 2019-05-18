import 'package:flutter/material.dart';
import 'package:wyob/data/LocalDatabase.dart';
import 'package:wyob/iob/IobConnector.dart';

class IobStateWidget extends StatefulWidget {

  final LocalDatabase _database;

  IobStateWidget(this._database);

  _IobStateWidgetState createState() => _IobStateWidgetState();
}

class _IobStateWidgetState extends State<IobStateWidget> {

  CONNECTOR_STATUS _connectorStatus;

  @override
  void initState() {
    super.initState();
    widget._database.onConnectorStatusChanged = this._handleConnectorStatusChange;
  }

  void _handleConnectorStatusChange(CONNECTOR_STATUS newStatus) {
    setState(() {
      this._connectorStatus = newStatus;
    });
  }

  String _getMessage() {
    return _connectorStatus.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(this._getMessage()),
      ],
    );
  }
}
