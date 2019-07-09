import 'package:flutter/material.dart';

import 'package:wyob/objects/Duty.dart' show Duty;
import 'package:wyob/utils/DateTimeUtils.dart';
import 'WidgetUtils.dart';
import 'package:wyob/pages/FlightDutyScreen.dart';


/// Widget containing the ListView of DutyWidgets, built from a List of
/// Duties
class DutiesWidget extends StatefulWidget {

  final List<Duty> duties;

  DutiesWidget(this.duties);

  _DutiesWidgetState createState() => _DutiesWidgetState();
}

class _DutiesWidgetState extends State<DutiesWidget> {

  @override
  Widget build(BuildContext context) {

    return Expanded(
      flex: 7,
      child: widget.duties == null ?
        Container() :
        ListView.builder(
          itemCount: widget.duties.length,
          //itemExtent: 100.0,
          itemBuilder: (context, index) {
            return DutyWidget(widget.duties[index]);
          },
      )
    );
  }
}

class DutyWidget extends StatelessWidget {

  final Duty _duty;

  DutyWidget(this._duty);

  Text get sectorsText {
    if (_duty.isFlight) {
      String stringSectors = _duty.flights[0].startPlace.IATA;
      for (int i = 0; i < _duty.flights.length; i++) {
        stringSectors += ' - ' + _duty.flights[i].endPlace.IATA;
      }
      return Text(stringSectors, textScaleFactor: 1.2,);
    } else if (_duty.isLayover) {
      return Text(_duty.code + ' ' + _duty.startPlace.IATA, textScaleFactor: 1.2,);
    } else {
      return Text(_duty.code, textScaleFactor: 1.2,);
    }
  }

  Widget _getTrailingIcon(BuildContext context) {
    if (_duty.isFlight) {
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

  Widget _getLocalStartDayText() {
    return Text(_duty.startTime.localDayString, textScaleFactor: 0.9);
  }

  Widget _getLocalEndDayText() {
    return Text(_duty.endTime.localDayString, textScaleFactor: 0.9);
  }

  Widget _getUpperRow() {
    // If reporting time is relevant
    if (_duty.isFlight) {
      return Row(
        children: <Widget>[
          _getLocalStartDayText(),
          Spacer(),
          ReportingTimeWidget(_duty.startTime.localTimeString),
        ],
      );
    } else if (_duty.isWorkingDuty || _duty.isStandby) {
      return Row(
        children: <Widget>[
          _getLocalStartDayText(),
          Spacer(),
          StandbyTimesWidget(
              _duty.startTime.localTimeString,
              _duty.endTime.localTimeString
          ),
        ],
      );
    } else if (_duty.isLayover) {
      return LayoverTimingWidget(durationToStringHM(_duty.duration));
    } else {
      return Row(
        children: <Widget>[
          _getLocalStartDayText(),
          Spacer(),
        ],
      );
    }
  }

  Widget _getLowerRow() {
    if (_duty.isLayover) return null; // No day on Layovers
    if (_duty.startTime.localDayString != _duty.endTime.localDayString) {
      return Row(children: <Widget>[_getLocalEndDayText()],);
    }
    return null;
  }

  Widget _getCentralWidget() {
    var widgets = <Widget>[];

    Widget upperRow = _getUpperRow();
    Widget centerText = Center(child: this.sectorsText,);
    Widget lowerRow = _getLowerRow();

    if (upperRow != null) widgets.add(upperRow);
    widgets.add(centerText);
    if (lowerRow != null) widgets.add(lowerRow);

    return Column(
      children: widgets,
    );
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

    if (_duty.acknowledge) return Colors.redAccent;

    return Colors.white;
  }

  @override
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
            //Text(_duty.natureAsString)
          ],
        ),
        title: _getCentralWidget(),
        trailing: _getTrailingIcon(context),
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

class LayoverTimingWidget extends StatelessWidget {

  final String durationString;

  LayoverTimingWidget(this.durationString);

  @override
  Widget build(BuildContext context) {
    return Text(
      durationString,
      textScaleFactor: 0.9,
      style: TextStyle(color: Colors.redAccent),
    );
  }
}
