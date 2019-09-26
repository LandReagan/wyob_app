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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<IobConnectorData>(
      valueListenable: onConnectorData,
      builder: (context, onConnectorData, _) {
        return Row(
          children: <Widget>[
            Text(onConnectorData.statusString),
          ],
        );
      },
    );
  }
}
