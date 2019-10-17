import 'package:flutter/material.dart';

enum STANDBY_TYPE { AIRPORT, HOME }

class StandbyTypeWidget extends StatefulWidget {

  final ValueChanged<STANDBY_TYPE> callback;

  StandbyTypeWidget(this.callback);

  _StandbyTypeWidgetState createState() => _StandbyTypeWidgetState();
}

class _StandbyTypeWidgetState extends State<StandbyTypeWidget> {

  STANDBY_TYPE type = STANDBY_TYPE.HOME;

  void _changeValue(STANDBY_TYPE value) {
    setState(() {
      type = value;
      widget.callback(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.all(5.0),
      child: Column(
        children: <Widget>[
          Text('StandBy type', style: TextStyle(fontStyle: FontStyle.italic),),
          Center(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Radio<STANDBY_TYPE>(
                      groupValue: type,
                        value: STANDBY_TYPE.HOME,
                        onChanged: (value) {
                          _changeValue(value);
                        },
                      ),
                      Text('HOME')
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Radio<STANDBY_TYPE>(
                        groupValue: type,
                        value: STANDBY_TYPE.AIRPORT,
                        onChanged: (value) {
                          _changeValue(value);
                        },
                      ),
                      Text('AIRPORT')
                    ],
                  )
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
