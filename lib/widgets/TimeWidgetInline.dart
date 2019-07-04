import 'package:flutter/material.dart';
import 'package:wyob/utils/DateTimeUtils.dart';

class TimeWidgetInline extends StatelessWidget {

  final AwareDT _time;
  final double _textScaleFactor;

  TimeWidgetInline(this._time, this._textScaleFactor);

  double get lowerScale => _textScaleFactor * 0.80;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(_time.localTimeString + ' ', textScaleFactor: _textScaleFactor,),
        Text(_time.utcTimeString, textScaleFactor: lowerScale,
          style: TextStyle(color: Colors.lightBlue),
        )
      ],
    );
  }
}
