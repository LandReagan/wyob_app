import 'package:flutter/material.dart';
import 'package:wyob/data/LocalDatabase.dart';
import 'package:wyob/iob/IobConnector.dart';

class IobStateWidget extends StatefulWidget {

  final IobConnector connector;

  IobStateWidget(this.connector);

  _IobStateWidgetState createState() => _IobStateWidgetState();
}

class _IobStateWidgetState extends State<IobStateWidget> {

  CONNECTOR_STATUS _connectorStatus = CONNECTOR_STATUS.OFF;
  LocalDatabase database;

  @override
  void initState() {
    super.initState();
    database = LocalDatabase();
    database.connector.onStatusChanged.addListener(this._handleConnectorStatusChange);
  }

  void _handleConnectorStatusChange() {
    setState(() {
      this._connectorStatus = widget.connector.status;
    });
  }

  @override
  void dispose() {
    database.connector.onStatusChanged.removeListener(this._handleConnectorStatusChange);
    super.dispose();
  }

  String _getMessage() {
    switch (_connectorStatus) {
      case CONNECTOR_STATUS.OFF:
        return 'OFF';
        break;

      case CONNECTOR_STATUS.AUTHENTIFIED:
        return 'AUTHENTIFIED!';
        break;

      case CONNECTOR_STATUS.CONNECTING:
        return 'CONNECTING...';
        break;

      case CONNECTOR_STATUS.CONNECTED:
        return 'CONNECTED!';
        break;

      case CONNECTOR_STATUS.FETCHING_GANTT_TABLE:
        return 'FETCHING GANTT TABLE...';
        break;

      case CONNECTOR_STATUS.FETCHING_DUTIES:
        return 'FETCHING DUTIES...';
        break;

      case CONNECTOR_STATUS.ERROR:
        return 'ERROR!';

        break;

      case CONNECTOR_STATUS.LOGIN_FAILED:
        return 'LOGIN FAILED!';
        break;

      case CONNECTOR_STATUS.OFFLINE:
        return 'OFFLINE!';
        break;

      default:
        return '---';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(this._getMessage(), textAlign: TextAlign.center,),)
      ],
    );
  }
}
