import 'package:flutter/material.dart';

import '../Duty.dart' show Duty;
import 'WidgetUtils.dart';
import 'FlightDutyScreen.dart';


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
  Text _text;
  Text _subText;

  DutyWidget(this._duty) {
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

    _text = new Text(sText);
    _subText = new Text(sSubText);
  }

  void _goToFlightDutyScreen() {
    Navigator.push(
        _context,
        MaterialPageRoute(
            builder: (_context) => FlightDutyScreen(_duty),
        ),
    );
  }

  Widget build(BuildContext context) {
    _context = context;
    return ListTile(
      contentPadding: EdgeInsets.all(10.0),
      leading: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _icon,
          Text(_duty.nature)
        ],
      ),
      title: _text,
      subtitle: _subText,
      // TODO: put it under condition to be determined?
      trailing: _trailingIcon,
    );
  }
}