import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class FltNumberWidget extends StatefulWidget {

  final String title;
  final String initialFlightNumber;
  final ValueChanged<DateTime> callback;

  FltNumberWidget(this.title, this.initialFlightNumber, this.callback);

  _FltNumberWidgetState createState() => _FltNumberWidgetState();
}

class _FltNumberWidgetState extends State<FltNumberWidget> {

  String _number;

  void initState() {
    super.initState();
    _number = widget.initialFlightNumber;
  }

  String get flightNumber {
    if (_number == null) {
      return 'Insert';
    } else {
      if (_number.contains("WY")) {
        return _number;
      } else {
        return "WY" + _number;
      }
    }
  }

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5.0),
      child: Column(
        children: <Widget>[
          Text(widget.title, style: TextStyle(fontStyle: FontStyle.italic),),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              prefixText: "WY"
            )
          )
        ],
      ),
    );
  }
}
