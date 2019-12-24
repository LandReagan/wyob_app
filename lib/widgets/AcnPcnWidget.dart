import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wyob/objects/AcnPcn.dart';

class AcnPcnWidget extends StatefulWidget {

  final List<String> _aircraftNames =
      getAircrafts().map((aircraft) => aircraft.name).toList();

  _AcnPcnWidgetState createState() => _AcnPcnWidgetState();
}

class _AcnPcnWidgetState extends State<AcnPcnWidget> {

  String _aircraft = 'A332';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text('AIRCRAFT:', textAlign: TextAlign.center, textScaleFactor: 1.5,),
        DropdownButton(
          value: _aircraft,
          icon: Icon(Icons.arrow_downward),
          onChanged: (String newValue) {
            setState(() {
              _aircraft = newValue;
            });
          },
          items: widget._aircraftNames.map((String name) {
            return DropdownMenuItem (
              value: name,
              child: Text(name),
            );
          }).toList(),
        ),
      ],
    );
  }
}