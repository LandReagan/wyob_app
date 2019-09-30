import 'package:flutter/material.dart';
import 'package:wyob/iob/IobConnector.dart';
import 'package:wyob/iob/IobConnectorData.dart';

class IobStateWidget extends StatefulWidget {

  final IobConnector connector;

  IobStateWidget(this.connector);

  _IobStateWidgetState createState() => _IobStateWidgetState();
}

class _IobStateWidgetState extends State<IobStateWidget> {

  ValueNotifier<IobConnectorData> onConnectorData;

  @override
  void initState() {
    super.initState();
    onConnectorData = widget.connector.onDataChange;
  }

  FlatButton getButton() {
    List<CONNECTOR_STATUS> updateButtonStates = [
      CONNECTOR_STATUS.OFFLINE,
      CONNECTOR_STATUS.OFF,
      CONNECTOR_STATUS.ERROR
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
        onPressed: () => null,
      );
    } else if (stopButtonStates.contains(onConnectorData.value.status)) {
      return FlatButton(
        child: Text("STOP"),
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
