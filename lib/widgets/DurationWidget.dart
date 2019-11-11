import 'package:flutter/material.dart';

class DurationWidget extends StatelessWidget {

  final Duration _duration;
  final double textScaleFactor;
  final Color textColor;

  DurationWidget(
    this._duration,
    {this.textScaleFactor = 1.5, this.textColor = Colors.black});

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
        Text(hoursString, textScaleFactor: textScaleFactor,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        Text('h' + minutesString, textScaleFactor: textScaleFactor * 3 / 4,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),)
      ],
    );
  }
}
