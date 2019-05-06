import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class FtlTimeWidget extends StatefulWidget {

  final String title;
  FtlTimeWidget(this.title);

  _FtlTimeWidgetState createState() => _FtlTimeWidgetState();
}

class _FtlTimeWidgetState extends State<FtlTimeWidget> {

  TimeOfDay _time;

  String get dateString {
    if (_time == null) {
      return 'Tap here';
    } else {
      String result = '';
      if (_time.hour < 10) result += '0';
      result += _time.hour.toString() + ':';
      if (_time.minute < 10) result += '0';
      result += _time.minute.toString();
      return result;
    }
  }

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5.0),
      child: Column(
        children: <Widget>[
          Text(widget.title, style: TextStyle(fontStyle: FontStyle.italic),),
          GestureDetector(
            child: Text(dateString, textScaleFactor: 1.2,),
            onTap: () async => _time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now()
            ),
          )
        ],
      ),
    );
  }
}
