import 'package:async/async.dart';

import 'package:flutter/material.dart';
import 'package:wyob/data/LocalDatabase.dart';
import 'package:wyob/iob/IobConnectorData.dart';

class IobStateWidget extends StatefulWidget {

  final VoidCallback _refreshDutiesCallback;

  IobStateWidget(this._refreshDutiesCallback);

  _IobStateWidgetState createState() => _IobStateWidgetState();
}

class _IobStateWidgetState extends State<IobStateWidget> {

  ValueNotifier<IobConnectorData> onConnectorData;

  @override
  void initState() {
    super.initState();
    onConnectorData = LocalDatabase().connector.onDataChange;
  }

  FlatButton getButton() {
    List<CONNECTOR_STATUS> updateButtonStates = [
      CONNECTOR_STATUS.OFFLINE,
      CONNECTOR_STATUS.OFF,
      CONNECTOR_STATUS.ERROR,
      CONNECTOR_STATUS.LOGIN_FAILED,
    ];
    List<CONNECTOR_STATUS> stopButtonStates = [
      CONNECTOR_STATUS.CONNECTING,
      CONNECTOR_STATUS.CONNECTED,
      CONNECTOR_STATUS.AUTHENTIFIED,
      CONNECTOR_STATUS.FETCHING_GANTT_TABLE,
      CONNECTOR_STATUS.FETCHING_DUTY
    ];

    if (updateButtonStates.contains(onConnectorData.value.status)) {
      return FlatButton(
        child: Text("UPDATE"),
        onPressed: () {
          LocalDatabase().updateFromGantt(callback: widget._refreshDutiesCallback);
        },
      );
    } else if (stopButtonStates.contains(onConnectorData.value.status)) {
      return FlatButton(
        child: Text("STOP"),
        onPressed: () => LocalDatabase().updateOperation.cancel(),
      );
    } else {
      return FlatButton(
        child: Text("?!?"),
        onPressed: () => null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<IobConnectorData>(
      valueListenable: onConnectorData,
      builder: (context, onConnectorData, _) {
        return Row(
          children: <Widget>[
            Expanded(
              child: Text(onConnectorData.statusString, textAlign: TextAlign.center,),
            ),
            getButton(),
          ],
        );
      },
    );
  }
}
