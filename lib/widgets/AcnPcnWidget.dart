import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wyob/objects/AcnPcn.dart';

class AcnPcnWidget extends StatefulWidget {
  final List<String> _aircraftNames =
      getAircrafts().map((aircraft) => aircraft.name).toList();

  _AcnPcnWidgetState createState() => _AcnPcnWidgetState();
}

class _AcnPcnWidgetState extends State<AcnPcnWidget> {
  String _aircraftName = 'A332';
  Aircraft _aircraft;
  Runway _runway;

  int _pcn;
  String _pavementType = '?';
  String _subgradeStrength = '?';
  String _tirePressure = '?';
  String _calculationMethod = '?';

  int _acnMax;
  int _acnEmpty;

  final _pcnController = TextEditingController();

  bool _tirePressureOK;
  int _maxAircraftWeight;

  @override
  void initState() {
    super.initState();
    _aircraft =
        getAircrafts().firstWhere((aircraft) => aircraft.name == _aircraftName);
    _pcnController.addListener(() {
      final txt = _pcnController.text;
      if (txt != null && txt != '') _pcn = int.tryParse(txt);
      setState(() {

      });
    });
  }

  @override
  void dispose() {
    _pcnController.dispose();
    super.dispose();
  }

  void _process() {
    if (_aircraft == null) return;
    if (_pavementType != '?' && _subgradeStrength != '?') {
      // We can get ACN max and ACN empty
      String type = _pavementType == 'R' ? 'rigid' : 'flexible';
      _acnMax = _aircraft.pavementSubgrades[type][_subgradeStrength]['max'];
      _acnEmpty = _aircraft.pavementSubgrades[type][_subgradeStrength]['min'];
    } else {
      _acnMax = null;
      _acnEmpty = null;
    }
    print(_aircraft.toString() +
        '\n' +
        'ACN MAX:' +
        _acnMax.toString() +
        ' - ACN EMPTY:' +
        _acnEmpty.toString());

    if (_pcn != null &&
        _pavementType != '?' &&
        _subgradeStrength != '?' &&
        _tirePressure != '?') {
      String runwayCode = _pcn.toString() +
              '/' +
              _pavementType +
              '/' +
              _subgradeStrength +
              '/' +
              _tirePressure +
              '/' +
              _calculationMethod ??
          '?';
      _runway = Runway.fromString(runwayCode);
      print(_runway);
    } else {
      _runway = null;
    }

    if (_runway != null && _acnMax != null && _acnEmpty != null) {
      _maxAircraftWeight = (_aircraft.maximumApronMass -
          (_acnMax - _pcn) / (_acnMax - _acnEmpty) *
          (_aircraft.maximumApronMass - _aircraft.operatingMassEmpty)).floor();
    } else {
      _maxAircraftWeight = null;
    }

    if (_aircraft != null && _tirePressure != '?') {
        if(_aircraft
            .standardAircraftTirePressure
            .checkPermissible(_tirePressure)) {
          _tirePressureOK = true;
        } else {
          _tirePressureOK = false;
        }
    } else {
      _tirePressureOK = null;
    }
  }

  List<Widget> getWidgets() {
    var widgets = <Widget>[];

    widgets.addAll([
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: Text(
              'AIRCRAFT:', textScaleFactor: 1.5, textAlign: TextAlign.right,),
          ),
          DropdownButton(
            value: _aircraftName,
            icon: Icon(Icons.arrow_downward),
            onChanged: (String newValue) {
              setState(() {
                _aircraftName = newValue;
                _aircraft = getAircrafts()
                    .firstWhere((aircraft) => aircraft.name == _aircraftName);
              });
            },
            items: widget._aircraftNames.map((String name) {
              return DropdownMenuItem(
                value: name,
                child: Text(
                  name,
                  textScaleFactor: 1.5,
                ),
              );
            }).toList(),
          ),
        ],
      ),
      Divider(
        height: 5.0,
      ),
      Text(
        'RUNWAY:',
        textScaleFactor: 1.5,
      ),
      Row(
        children: <Widget>[
          Expanded(
            child: TextField(
                decoration: InputDecoration(
                  hintText: 'PCN',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22.0),
                controller: _pcnController),
          ),
          Text(
            '/',
            textScaleFactor: 1.5,
          ),
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
                  child: Text(
                    '?',
                    textScaleFactor: 1.5,
                  ),
                ),
                DropdownMenuItem(
                  value: 'R',
                  child: Text(
                    'R',
                    textScaleFactor: 1.5,
                  ),
                ),
                DropdownMenuItem(
                  value: 'F',
                  child: Text(
                    'F',
                    textScaleFactor: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '/',
            textScaleFactor: 1.5,
          ),
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
                  child: Text(
                    '?',
                    textScaleFactor: 1.5,
                  ),
                ),
                DropdownMenuItem(
                  value: 'A',
                  child: Text(
                    'A',
                    textScaleFactor: 1.5,
                  ),
                ),
                DropdownMenuItem(
                  value: 'B',
                  child: Text(
                    'B',
                    textScaleFactor: 1.5,
                  ),
                ),
                DropdownMenuItem(
                  value: 'C',
                  child: Text(
                    'C',
                    textScaleFactor: 1.5,
                  ),
                ),
                DropdownMenuItem(
                  value: 'D',
                  child: Text(
                    'D',
                    textScaleFactor: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '/',
            textScaleFactor: 1.5,
          ),
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
                  child: Text(
                    '?',
                    textScaleFactor: 1.5,
                  ),
                ),
                DropdownMenuItem(
                  value: 'W',
                  child: Text(
                    'W',
                    textScaleFactor: 1.5,
                  ),
                ),
                DropdownMenuItem(
                  value: 'X',
                  child: Text(
                    'X',
                    textScaleFactor: 1.5,
                  ),
                ),
                DropdownMenuItem(
                  value: 'Y',
                  child: Text(
                    'Y',
                    textScaleFactor: 1.5,
                  ),
                ),
                DropdownMenuItem(
                  value: 'Z',
                  child: Text(
                    'Z',
                    textScaleFactor: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '/',
            textScaleFactor: 1.5,
          ),
          Expanded(
            child: DropdownButton(
              value: _calculationMethod,
              onChanged: (String newMethod) {
                setState(() {
                  _calculationMethod = newMethod;
                });
              },
              items: [
                DropdownMenuItem(
                  value: '?',
                  child: Text(
                    '?',
                    textScaleFactor: 1.5,
                  ),
                ),
                DropdownMenuItem(
                  value: 'T',
                  child: Text(
                    'T',
                    textScaleFactor: 1.5,
                  ),
                ),
                DropdownMenuItem(
                  value: 'U',
                  child: Text(
                    'U',
                    textScaleFactor: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      Divider(
        height: 15.0,
      )
    ]);

    if (_acnMax != null && _acnEmpty != null) {
      widgets.add(
        Row(
          children: <Widget>[
            Text('ACN MAX: ', textScaleFactor: 1.5,),
            Text(_acnMax.toString(), textScaleFactor: 1.5, style: TextStyle(color: Colors.blue),),
            Spacer(),
            Text('ACN EMPTY: ', textScaleFactor: 1.5,),
            Text(_acnEmpty.toString(), textScaleFactor: 1.5, style: TextStyle(color: Colors.blue),)
          ],
        )
      );
    }

    if (_maxAircraftWeight != null && _maxAircraftWeight < _aircraft.maximumApronMass) {
      widgets.addAll(<Widget>[
        Divider(),
        Text('MAX A/C WEIGHT: ', textScaleFactor: 1.5,),
        Text(_maxAircraftWeight.toString(), textScaleFactor: 1.5,
          style: TextStyle(color: Colors.amber),)
      ]);
    } else if (_maxAircraftWeight != null && _maxAircraftWeight >= _aircraft.maximumApronMass) {
      widgets.addAll(<Widget>[
        Divider(),
        Text('MAX A/C WEIGHT: ', textScaleFactor: 1.5,),
        Text('UNRESTRICTED', textScaleFactor: 1.5,
          style: TextStyle(color: Colors.green),)
      ],);
    }

    if (_tirePressureOK != null) {
      widgets.addAll([
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('TIRE PRESSURE: ', textScaleFactor: 1.5,),
            _tirePressureOK ?
              Text('OK', textScaleFactor: 1.5, style: TextStyle(color: Colors.green),) :
              Text('NOK', textScaleFactor: 1.5, style: TextStyle(color: Colors.red),),
          ],
        )
      ]);
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    _process();
    return Column(
      children: getWidgets(),
    );
  }
}
