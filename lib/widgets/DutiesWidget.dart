import 'package:flutter/material.dart';

import 'package:wyob/objects/Duty.dart' show Duty;
import 'WidgetUtils.dart';
import 'package:wyob/pages/FlightDutyScreen.dart';

/// Widget containing the ListView of DutyWidgets, built from a List of
/// Duties
///
///
class DutiesWidget extends StatelessWidget {

  final List<Duty> duties;

  DutiesWidget(this.duties);

  @override
  Widget build(BuildContext context) {
    return new Expanded(
      flex: 7,
      child: duties == null ? new Container() : new ListView.builder(
        itemCount: duties.length,
        itemBuilder: (context, index) {
          return DutyWidget(duties[index]);
        }
      )
    );
  }
}

class DutyWidget extends StatelessWidget {

  BuildContext _context;
  
  Duty _duty;
  Widget _icon;
  Widget _trailingIcon;

  Text _localDayText;
  Text _sectorsText;
  Widget _upperRowWidget;
  Widget _centralWidget;

  DutyWidget(this._duty) {

    _localDayText = Text(_duty.startTime.localDayString, textScaleFactor: 0.9);

    if (_duty.nature == 'FLIGHT') {

      String stringSectors = _duty.flights[0].startPlace.IATA;
      for (int i = 0; i < _duty.flights.length; i++) {
        stringSectors += ' - ' + _duty.flights[i].endPlace.IATA;
      }
      _sectorsText = Text(stringSectors, textScaleFactor: 1.2,);

      _upperRowWidget = Row(
        children: <Widget>[
          _localDayText,
          Spacer(),
          ReportingTimeWidget(_duty.startTime.localTimeString),
        ],
      );

    } else if (_duty.nature == 'STDBY') {
      _sectorsText = Text(_duty.code, textScaleFactor: 1.2,);
    }

    if (_upperRowWidget != null) {
      _centralWidget = Column(
        children: <Widget>[
          _upperRowWidget,
          Center(
            child: _sectorsText,
          )
        ],
      );
    } else {
      _centralWidget = Column(
        children: <Widget>[
          Center(
            child: _sectorsText,
          )
        ],
      );
    }

    _icon = WidgetUtils.getIconFromDutyNature(_duty.nature);
    _trailingIcon = null;

    // Text building
    String sText = "";
    String sSubText = "";
    sText += _duty.startTime.localDayString;
    sText += " ";

    if (_duty.nature == "FLIGHT") {
      sText += "report " + _duty.startTime.localTimeString;
      sSubText += _duty.startPlace.IATA + ' ';
      sSubText += _duty.flights[0].startTime.localTimeString;
      sSubText += '  to  ' + _duty.endPlace.IATA + ' ' + _duty.endTime.localTimeString;
      _trailingIcon = new IconButton(
        icon: Icon(Icons.arrow_forward),
        onPressed: () {
          _goToFlightDutyScreen();
        },
      );
    }

    if (_duty.nature == "STDBY") {
      sSubText += _duty.startTime.localTimeString
      + ' to ' + _duty.endTime.localTimeString;
    }
  }

  void _goToFlightDutyScreen() {
    Navigator.push(
        _context,
        MaterialPageRoute(
            builder: (_context) => FlightDutyScreen(_duty),
        ),
    );
  }

  Color _getDutyColor() {
    if (_duty.endTime.loc.difference(DateTime.now()).inMinutes < 0) {
      return Colors.grey;
    } // TODO: color for "acknowledge" duties

    return Colors.white;
  }

  Widget build(BuildContext context) {
    _context = context;
    return Container(
      decoration: BoxDecoration(
        color: _getDutyColor(),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(10.0),
        leading: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _icon,
            Text(_duty.nature)
          ],
        ),
        /*
        title: _text,
        subtitle: _subText,
        */
        title: _centralWidget,
        trailing: _trailingIcon,
      ),
    );
  }
}

class ReportingTimeWidget extends StatelessWidget {

  final String reportingTimeString;

  ReportingTimeWidget(this.reportingTimeString);

  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(Icons.timer, color: Colors.redAccent,),
        Text(
          reportingTimeString,
          style: TextStyle(color: Colors.redAccent),
          textScaleFactor: 0.9,
        )
      ],
    );
  }
}