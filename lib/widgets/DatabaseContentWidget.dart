import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:wyob/data/LocalDatabase.dart';
import 'package:wyob/objects/Duty.dart';
import 'package:wyob/objects/FTL.dart';
import 'package:wyob/objects/MonthlyAggregation.dart';
import 'package:wyob/objects/Statistics.dart';
import 'package:wyob/utils/DateTimeUtils.dart';

class DatabaseByMonthWidget extends StatefulWidget {

  final LocalDatabase database;

  DatabaseByMonthWidget(this.database);

  _DatabaseByMonthWidgetState createState() => _DatabaseByMonthWidgetState();
}

class _DatabaseByMonthWidgetState extends State<DatabaseByMonthWidget> {

  Widget getMonthWidget(MonthlyAggregation aggregation) {
    List<Map<String, dynamic>> aggregDataList = aggregation.dutiesAndStatistics;

    var days = <DateTime>[];
    for (
    DateTime dt = aggregation.monthStart;
    dt.isBefore(aggregation.monthEnd);
    dt = dt.add(Duration(days: 1))) {
      days.add(dt);
    }
    aggregDataList.forEach((data) {
      Duty duty = data['duty'];
      days.removeWhere((day) => day.day == duty.startTime.loc.day);
      days.removeWhere((day) => day.day == duty.endTime.loc.day);
    });

    List<Widget> dayWidgets = List.generate(
        aggregDataList.length,
            (int index) {
          Duty duty = aggregDataList[index]['duty'];
          Statistics stat = aggregDataList[index]['stat'];
          return RawDutyWidget(duty, stat);
        }
    );

    days.forEach((dt) {
      dayWidgets.add(BlankDayWidget(dt));
    });

    dayWidgets.sort((first, second) {
      DateTime dtFirst;
      DateTime dtSecond;
      if (first is RawDutyWidget) {
        dtFirst = first.duty.startTime.loc;
      } else if (first is BlankDayWidget) {
        dtFirst = first.date;
      }
      if (second is RawDutyWidget) {
        dtSecond = second.duty.startTime.loc;
      } else if (second is BlankDayWidget) {
        dtSecond = second.date;
      }
      return dtFirst.compareTo(dtSecond);
    });

    return ExpansionTile(
      title: Text(aggregation.titleString, textScaleFactor: 1.3,),
      children: dayWidgets,
    );
  }

  List<Widget> _getMonthTiles() {
    var widgets = <Widget>[];
    widget.database.getAllMonthlyAggregations().forEach((aggregation) {
      widgets.add(MonthlyStatisticsWidget(aggregation));
      widgets.add(getMonthWidget(aggregation));
    });
    return widgets.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _getMonthTiles(),
    );
  }
}

class BlankDayWidget extends StatelessWidget {
  final DateTime date;

  BlankDayWidget(this.date);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.limeAccent,
          ),
          child: Row(
            children: <Widget>[
              Text(dateToString(date)),
              Expanded(child: Text('BLANK DAY!', textAlign: TextAlign.center,),),
            ]
          )
        ),
        Divider(color: Colors.black,),
      ],
    );
  }
}

class RawDutyWidget extends StatelessWidget {

  final Duty duty;
  final Statistics statistics;

  static const BOLD = TextStyle(fontWeight: FontWeight.bold);
  static const ITALIC = TextStyle(fontStyle: FontStyle.italic);

  static const PALE_GREY = Color.fromRGBO(230, 230, 230, 1.0);

  RawDutyWidget(this.duty, this.statistics);

  Widget getStartDateWidget() {
    var widgets = <Widget>[];
    widgets.add(Expanded(child: Text(duty.startTime.localDayString)));
    if (duty.isWorkingDuty) {
      widgets.add(Text('REPORTING: '));
      widgets.add(
          Expanded(child: Text(duty.startTime.localTimeString, style: BOLD,)));
    }

    return Row(
        children: widgets
    );
  }

  Widget getEndDateWidget() {
    var widgets = <Widget>[];
    if (duty.startTime.localDayString != duty.endTime.localDayString) {
      widgets.add(Expanded(child: Text(duty.endTime.localDayString),),);
    } else {
      widgets.add(Expanded(child: Text(''),));
    }

    if (duty.isWorkingDuty) {
      widgets.add(Text('OFF DUTY: '));
      widgets.add(
          Expanded(child: Text(duty.endTime.localTimeString, style: BOLD,)));
    }

    return Row(
      children: widgets,
    );
  }

  Widget getHeaderWidget() {
    return Row(
      children: <Widget>[
        Expanded(child: Text(duty.nature ?? '', style: BOLD,),),
        Text('CODE: '),
        Expanded(child: Text(duty.code ?? '---', style: BOLD,),),
        Text('STATUS: '),
        Expanded(child: Text(duty.statusAsString ?? '', style: BOLD,),),
      ],
    );
  }

  List<Widget> getFlightsWidgets() {
    List<Widget> flightWidgets = [];
    duty.flights.forEach((flight) {
      flightWidgets.add(
          Container(
            decoration: BoxDecoration(
                color: PALE_GREY
            ),
            child: Row(
              children: <Widget>[
                Expanded(child: Text(flight.flightNumber ?? '', style: BOLD,),),
                Text(flight.startPlace.IATA + ' ', style: BOLD,),
                Text(flight.startTime.localTimeString + ' ', style: BOLD),
                Expanded(
                  child: Text(flight.startTime.utcTimeString, style: ITALIC),),
                Text(flight.endPlace.IATA + ' ', style: BOLD,),
                Text(flight.endTime.localTimeString + ' ', style: BOLD,),
                Expanded(
                  child: Text(flight.endTime.utcTimeString, style: ITALIC,),),
                Text(flight.durationString, style: BOLD,),
              ],
            ),
          )
      );
    });
    return flightWidgets;
  }

  Widget getStandByWidget() {
    return Row(
      children: <Widget>[
        Text('from:', style: ITALIC,),
        Expanded(child: Text(duty.startTime.localTimeString, style: BOLD,),),
        Text('to:', style: ITALIC,),
        Expanded(child: Text(duty.endTime.localTimeString, style: BOLD,),),
      ],
    );
  }

  List<Widget> getFDPWidgets() {
    FlightDutyPeriod fdp = duty.ftl.flightDutyPeriod;
    var widgets = <Widget>[];

    widgets.add(
        Row(
          children: <Widget>[
            Text('FDP start: '),
            Expanded(
              child: Text(
                fdp.start.localDayString + ' ' + fdp.start.localTimeString,
                style: ITALIC,
              ),
            ),
            Text('end: '),
            Expanded(
              child: Text(
                fdp.end.localDayString + ' ' + fdp.end.localTimeString,
                style: ITALIC,
              ),
            ),
          ],
        )
    );

    widgets.add(
        Row(
          children: <Widget>[
            Text('ACT: '),
            Expanded(child: Text(fdp.durationString, style: BOLD,),),
            Text('MAX: '),
            Expanded(child: Text(
              fdp.maxFlightDutyPeriod.durationString, style: BOLD,),),
            Text('EXT: '),
            Expanded(child: Text(
              fdp.extendedFlightDutyPeriod.durationString, style: BOLD,),),
          ],
        )
    );

    return widgets;
  }

  Widget getRestWidget() {
    return Row(
      children: <Widget>[
        Text('REST: '),
        Expanded(child: Text(duty.rest.durationString, style: BOLD,),),
        Text('ends: '),
        Expanded(
          child: Text(duty.rest.end.localDayString + ' ', style: BOLD,),),
        Expanded(child: Text(duty.rest.end.localTimeString, style: BOLD,),),
      ],
    );
  }

  Widget getStatisticsWidget() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text('DUTY ACCUMULATED (PREVIOUS X DAYS):', textAlign: TextAlign.center,),)
          ],
        ),
        Row(
          children: <Widget>[
            Text('7: ', style: TextStyle(fontWeight: FontWeight.bold),),
            Expanded(child: Text(durationToStringHM(statistics.sevenDaysDutyAccumulation)),),
            Text('28: ', style: TextStyle(fontWeight: FontWeight.bold),),
            Expanded(child: Text(durationToStringHM(statistics.twentyEightDaysDutyAccumulation)),),
            Text('365: ', style: TextStyle(fontWeight: FontWeight.bold),),
            Expanded(child: Text(durationToStringHM(statistics.oneYearDutyDaysAccumulation)),),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(child: Text('BLOCK ACCUMULATED (PREVIOUS X DAYS):', textAlign: TextAlign.center,),)
          ],
        ),
        Row(
          children: <Widget>[
            Text('28: ', style: TextStyle(fontWeight: FontWeight.bold),),
            Expanded(child: Text(durationToStringHM(statistics.twentyEightDaysBlockAccumulation)),),
            Text('365: ', style: TextStyle(fontWeight: FontWeight.bold),),
            Expanded(child: Text(durationToStringHM(statistics.oneYearBlockAccumulation)),),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    widgets.add(getStartDateWidget());
    widgets.add(getHeaderWidget());
    widgets.addAll(getFlightsWidgets());
    if (duty.nature == DUTY_NATURE.STDBY) widgets.add(getStandByWidget());
    if (getEndDateWidget() != null) widgets.add(getEndDateWidget());
    if (duty.nature == DUTY_NATURE.FLIGHT) widgets.addAll(getFDPWidgets());
    if (duty.isWorkingDuty) widgets.add(getRestWidget());
    widgets.add(getStatisticsWidget());
    widgets.add(Divider(color: Colors.black,));

    return Container(
      padding: EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        //todo
      ),
      child: Column(
          children: widgets
      ),
    );
  }
}

class MonthlyStatisticsWidget extends StatelessWidget {

  final MonthlyAggregation aggregation;
  Duration blockTime = Duration.zero;
  Duration dutyTime = Duration.zero;
  int nbrOfFlights = 0;
  int flyingAllowance = 0;

  MonthlyStatisticsWidget(this.aggregation) {
    aggregation.dutiesAndStatistics.forEach((Map<String, dynamic>data) {
      Duty duty = data['duty'];
      if (duty.isFlight) {
        blockTime += duty.totalBlockTime;
        nbrOfFlights += duty.flights.length;
      }
      if (duty.isWorkingDuty) {
        dutyTime += duty.duration;
      }
    });
  }

  List<Map<String, dynamic>> get revisedAggregationDutiesAndStatistics {
    return aggregation.dutiesAndStatistics.where((data) {
      return data['duty'].startTime.loc.month == aggregation.monthStart.month;
    });
  }

  Widget _getStatItem(String title, String value, VoidCallback callback) {

    List<Widget> widgets = [];
    widgets.add(Expanded(child: Text(title),));
    widgets.add(Text(value, textAlign: TextAlign.center,));
    if (callback != null) {
      widgets.add(
        IconButton(
          icon: Icon(Icons.info),
          onPressed: () { callback(); },
        )
      );
    }

    return Container(
      padding: EdgeInsets.all(5.0),
      child: Row(children: widgets),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        aggregation.titleString + ' Statistics',
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
      ),
      children: <Widget>[
        _getStatItem('BLOCK TIME: ', durationToStringHM(blockTime), null),
        _getStatItem('FLYING ALLOWANCE: ', flyingAllowance.toString(), null),
        _getStatItem('DUTY TIME: ', durationToStringHM(dutyTime), null),
        _getStatItem('FLIGHTS: ', nbrOfFlights.toString(), null),
      ],
    );
  }
}
