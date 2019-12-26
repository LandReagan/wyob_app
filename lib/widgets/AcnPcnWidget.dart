import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wyob/objects/AcnPcn.dart';

class AcnPcnWidget extends StatefulWidget {

  final List<String> _aircraftNames =
      getAircrafts().map((aircraft) => aircraft.name).toList();

  _AcnPcnWidgetState createState() => _AcnPcnWidgetState();
}

class _AcnPcnWidgetState extends State<AcnPcnWidget> {

  String _aircraft = 'A332';

  int _pcn;
  String _pavementType = '?';
  String _subgradeStrength = '?';
  String _tirePressure = '?';
  String _calculationMethod = '?';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'AIRCRAFT:',
                textScaleFactor: 1.5,
              ),
            ),
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
                    child: Text(name, textScaleFactor: 1.5,),
                  );
                }).toList(),
              ),
          ],
        ),
        Divider(height: 5.0,),
        Text(
          'RUNWAY:',
          textScaleFactor: 1.5,
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                decoration: InputDecoration(hintText: 'PCN', ),
              ),
            ),
            Text('/', textScaleFactor: 1.5,),
            Expanded(
              child: DropdownButton(
                value: _pavementType,
                onChanged: (String newType) {
                  setState(() {
                    _pavementType = newType;
                  });
                },
                items: [
                  DropdownMenuItem(
                    value: '?',
                    child: Text('?', textScaleFactor: 1.5,),
                  ),
                  DropdownMenuItem(
                    value: 'R',
                    child: Text('R', textScaleFactor: 1.5,),
                  ),
                  DropdownMenuItem(
                    value: 'F',
                    child: Text('F', textScaleFactor: 1.5,),
                  ),
                ],
              ),
            ),
            Text('/', textScaleFactor: 1.5,),
            Expanded(
              child: DropdownButton(
                value: _subgradeStrength,
                onChanged: (String newSubgrade) {
                  setState(() {
                    _subgradeStrength = newSubgrade;
                  });
                },
                items: [
                  DropdownMenuItem(
                    value: '?',
                    child: Text('?', textScaleFactor: 1.5,),
                  ),
                  DropdownMenuItem(
                    value: 'A',
                    child: Text('A', textScaleFactor: 1.5,),
                  ),
                  DropdownMenuItem(
                    value: 'B',
                    child: Text('B', textScaleFactor: 1.5,),
                  ),
                  DropdownMenuItem(
                    value: 'C',
                    child: Text('C', textScaleFactor: 1.5,),
                  ),
                  DropdownMenuItem(
                    value: 'D',
                    child: Text('D', textScaleFactor: 1.5,),
                  ),
                ],
              ),
            ),
            Text('/', textScaleFactor: 1.5,),
            Expanded(
              child: DropdownButton(
                value: _tirePressure,
                onChanged: (String newTire) {
                  setState(() {
                    _tirePressure = newTire;
                  });
                },
                items: [
                  DropdownMenuItem(
                    value: '?',
                    child: Text('?', textScaleFactor: 1.5,),
                  ),
                  DropdownMenuItem(
                    value: 'W',
                    child: Text('W', textScaleFactor: 1.5,),
                  ),
                  DropdownMenuItem(
                    value: 'X',
                    child: Text('X', textScaleFactor: 1.5,),
                  ),
                  DropdownMenuItem(
                    value: 'Y',
                    child: Text('Y', textScaleFactor: 1.5,),
                  ),
                  DropdownMenuItem(
                    value: 'Z',
                    child: Text('Z', textScaleFactor: 1.5,),
                  ),
                ],
              ),
            ),
            Text('/', textScaleFactor: 1.5,),
            Expanded(
              child: DropdownButton(
                value: _pavementType,
                onChanged: (String newType) {
                  setState(() {
                    _pavementType = newType;
                  });
                },
                items: [
                  DropdownMenuItem(
                    value: '?',
                    child: Text('?', textScaleFactor: 1.5,),
                  ),
                  DropdownMenuItem(
                    value: 'R',
                    child: Text('R', textScaleFactor: 1.5,),
                  ),
                  DropdownMenuItem(
                    value: 'F',
                    child: Text('F', textScaleFactor: 1.5,),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}