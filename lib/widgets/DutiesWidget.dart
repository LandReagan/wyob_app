import 'package:flutter/material.dart';

import 'package:wyob/objects/Duty.dart' show Duty;
import 'WidgetUtils.dart';
import 'package:wyob/pages/FlightDutyScreen.dart';

/// Widget containing the ListView of DutyWidgets, built from a List of
/// Duties
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

  final Duty _duty;

  DutyWidget(this._duty);

  Text get sectorsText {
    if (_duty.nature == 'FLIGHT') {

      String stringSectors = _duty.flights[0].startPlace.IATA;
      for (int i = 0; i < _duty.flights.length; i++) {
        stringSectors += ' - ' + _duty.flights[i].endPlace.IATA;
      }
      return Text(stringSectors, textScaleFactor: 1.2,);
    } else if (_duty.nature == 'STDBY') {
      return Text(_duty.code, textScaleFactor: 1.2,);
    }
    return null;
  }

  Widget getTrailingIcon(BuildContext context) {
    if (_duty.nature == "FLIGHT") {
      return IconButton(
        icon: Icon(Icons.arrow_forward_ios),
        onPressed: () {
          _goToFlightDutyScreen(context);
        },
      );
    } else {
      return null;
    }
  }

  Widget getLocalDayText() {
    return Text(_duty.startTime.localDayString, textScaleFactor: 0.9);
  }

  Widget getUpperRow() {
    // If reporting time is relevant
    if (_duty.nature == 'FLIGHT') {
      return Row(
        children: <Widget>[
          getLocalDayText(),
          Spacer(),
          ReportingTimeWidget(_duty.startTime.localTimeString),
        ],
      );
    } else if (_duty.nature == 'STDBY') {
      return Row(
        children: <Widget>[
          getLocalDayText(),
          Spacer(),
          StandbyTimesWidget(
            _duty.startTime.localTimeString,
            _duty.endTime.localTimeString
          ),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          getLocalDayText(),
          Spacer(),
        ],
      );
    }
  }

  Widget getCentralWidget() {
    if (getUpperRow() != null) {
      return Column(
        children: <Widget>[
          getUpperRow(),
          Center(
            child: this.sectorsText,
          ),
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          Center(
            child: this.sectorsText,
          ),
        ],
      );
    }
  }

  void _goToFlightDutyScreen(context) {
    Navigator.push(
        context,
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
    return Container(
      decoration: BoxDecoration(
        color: _getDutyColor(),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(10.0),
        leading: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            WidgetUtils.getIconFromDutyNature(_duty.nature),
            Text(_duty.nature)
          ],
        ),
        title: getCentralWidget(),
        trailing: getTrailingIcon(context),
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

class StandbyTimesWidget extends StatelessWidget {

  final String startTime;
  final String endTime;

  StandbyTimesWidget(this.startTime, this.endTime);

  @override
  Widget build(BuildContext context) {
    return Text(
      'from ' + startTime + ' to ' + endTime,
      textScaleFactor: 0.9,
      style: TextStyle(color: Colors.redAccent),
    );
  }
}
