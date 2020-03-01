import 'package:flutter/material.dart';

class StandbyToggleWidget extends StatefulWidget {

  final String title;
  final ValueChanged<bool> callback;
  final bool initialValue;

  StandbyToggleWidget(this.title, this.callback, this.initialValue);

  _StandbyToggleWidgetState createState() => _StandbyToggleWidgetState();
}

class _StandbyToggleWidgetState extends State<StandbyToggleWidget> {

  bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.0),
      child: Column(
        children: <Widget>[
          Text(widget.title, style: TextStyle(fontStyle: FontStyle.italic),),
          Switch(
            value: _value,
            onChanged: (boolValue) {
              setState(() {
                _value = boolValue;
              });
              widget.callback(boolValue);
            },
          )
        ],
      ),
    );
  }
}
