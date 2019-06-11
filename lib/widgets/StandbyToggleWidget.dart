import 'package:flutter/material.dart';

class StandbyToggleWidget extends StatefulWidget {

  final String title;
  final ValueChanged<bool> callback;

  StandbyToggleWidget(this.title, this.callback);

  _StandbyToggleWidgetState createState() => _StandbyToggleWidgetState();
}

class _StandbyToggleWidgetState extends State<StandbyToggleWidget> {

  bool value = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.all(5.0),
      child: Column(
        children: <Widget>[
          Text(widget.title, style: TextStyle(fontStyle: FontStyle.italic),),
          Switch(
            value: value,
            onChanged: (boolValue) {
              setState(() {
                value = boolValue;
              });
              widget.callback(boolValue);
            },
          )
        ],
      ),
    );
  }
}
