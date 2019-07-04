import 'package:flutter/material.dart';

class DurationWidget extends StatelessWidget {

  final Duration _duration;

  DurationWidget(this._duration);

  int get hours => _duration.inHours;
  int get minutes => _duration.inMinutes - hours * 60;

  String get hoursString {
    return hours.toString().length == 1 ?
        '0' + hours.toString() : hours.toString();
  }

  String get minutesString {
    return minutes.toString().length == 1 ?
      '0' + minutes.toString() : minutes.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(hoursString, textScaleFactor: 1.5,
          style: TextStyle(fontWeight: FontWeight.bold),),
        Text('h' + minutesString, textScaleFactor: 1.2,
          style: TextStyle(fontWeight: FontWeight.bold),)
      ],
    );
  }
}
