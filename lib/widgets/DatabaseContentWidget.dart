import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:wyob/data/LocalDatabase.dart';
import 'package:wyob/objects/Duty.dart';
import 'package:wyob/objects/FTL.dart';
import 'package:wyob/objects/MonthlyAggregation.dart';
import 'package:wyob/objects/Statistics.dart';
import 'package:wyob/utils/DateTimeUtils.dart';

class DatabaseByMonthWidget extends StatefulWidget{

  final LocalDatabase database;
  DatabaseByMonthWidget(this.database);

  _DatabaseByMonthWidgetState createState() => _DatabaseByMonthWidgetState();
}

class _DatabaseByMonthWidgetState extends State<DatabaseByMonthWidget> {

  Widget getMonthWidget(MonthlyAggregation aggregation) {
    List<Map<String, dynamic>> aggregDataList = aggregation.dutiesAndStatistics;
    return ExpansionTile(
      title: Text(aggregation.titleString),
      children: List.generate(
        aggregDataList.length,
        (int index) {
          Duty duty = aggregDataList[index]['duty'];
          Statistics stat = aggregDataList[index]['stat'];
          return RawDutyWidget(duty, stat);
        }
      ),
    );
  }

  List<Widget> _getMonthTiles() {
    var widgets = <Widget>[];
    widget.database.getAllMonthlyAggregations().forEach((aggregation) {
      widgets.add(getMonthWidget(aggregation));
    });
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _getMonthTiles(),
    );
  }
}

/* OBSOLETE
class DatabaseContentWidget extends StatelessWidget {

  final LocalDatabase database;

  DatabaseContentWidget(this.database);

  @override
  Widget build(BuildContext context) {
    List<Duty> duties = database.getDuties(
      DateTime(DateTime.now().year, DateTime.now().month, 1),
      DateTime(DateTime.now().year, DateTime.now().month + 1)
    );
    List<Statistics> statisticsList = database.buildStatistics();
    return ListView.builder(
      itemCount: duties.length,
      itemBuilder: (context, index) {
        Duty duty = duties[index];
        Statistics stat = statisticsList.firstWhere((stat) => stat.dutyID == duty.id);
        return RawDutyWidget(duty, stat);
      },
    );
  }
}
*/

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
    if (duty.nature == 'FLIGHT' || duty.nature == 'GROUND' || duty.nature == 'SIM') {
      widgets.add(Text('REPORTING: '));
      widgets.add(Expanded(child: Text(duty.startTime.localTimeString, style: BOLD,)));
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

    if (duty.nature == 'FLIGHT' || duty.nature == 'GROUND' || duty.nature == 'SIM') {
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
              Expanded(child: Text(flight.startTime.utcTimeString, style: ITALIC),),
              Text(flight.endPlace.IATA + ' ', style: BOLD,),
              Text(flight.endTime.localTimeString + ' ', style: BOLD,),
              Expanded(child: Text(flight.endTime.utcTimeString, style: ITALIC,),),
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
          Text('DURATION: '),
          Expanded(child: Text(fdp.durationString, style: BOLD,),),
          Text('MAX: '),
          Expanded(child: Text(fdp.maxFlightDutyPeriod.durationString, style: BOLD,),),
          Text('EXT: '),
          Expanded(child: Text(fdp.extendedFlightDutyPeriod.durationString, style: BOLD,),),
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
        Expanded(child: Text(duty.rest.end.localDayString + ' ', style: BOLD,),),
        Expanded(child: Text(duty.rest.end.localTimeString, style: BOLD,),),
      ],
    );
  }

  Widget getStatisticsWidget() {
    return Row(
      children: <Widget>[
        Text('BLOCK CUMUL: '),
        Text(durationToStringHM(statistics.accumulatedBlock)),
        Text('DUTY CUMUL: '),
        Text(durationToStringHM(statistics.accumulatedDuty)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> widgets = [];
    widgets.add(getStartDateWidget());
    widgets.add(getHeaderWidget());
    widgets.addAll(getFlightsWidgets());
    if (duty.nature == 'STDBY') widgets.add(getStandByWidget());
    if (getEndDateWidget() != null) widgets.add(getEndDateWidget());
    if (duty.nature == 'FLIGHT') widgets.addAll(getFDPWidgets());
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
