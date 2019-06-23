import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:wyob/objects/FTL.dart';
import 'package:wyob/utils/DateTimeUtils.dart';

class DutyPeriodWidget extends StatelessWidget {
  final FTL ftl;

  DutyPeriodWidget(this.ftl);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(color: Colors.amberAccent),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Text(
                'DUTY PERIOD:',
                textScaleFactor: 1.5,
              )),
              Center(
                child: Text(
                  ftl.dutyPeriod.durationString,
                  textScaleFactor: 1.5,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.amberAccent, width: 3.0),
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      ftl.dutyPeriod.start.localDayString + ' ',
                      textScaleFactor: 1.5,
                    ),
                  ),
                  Text('from '),
                  Text(ftl.dutyPeriod.start.localTimeString,
                      textScaleFactor: 1.5),
                  Text(' to '),
                  Text(ftl.dutyPeriod.end.localTimeString,
                      textScaleFactor: 1.5),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FlightDutyPeriodWidget extends StatelessWidget {
  final FTL ftl;

  FlightDutyPeriodWidget(this.ftl);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(color: Colors.deepOrangeAccent),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'FLIGHT DUTY PERIOD:',
                  textScaleFactor: 1.5,
                ),
              ),
              Center(
                child: Text(
                  ftl.flightDutyPeriod.durationString,
                  textScaleFactor: 1.5,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.deepOrangeAccent, width: 3.0),
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      ftl.flightDutyPeriod.start.localDayString + ' ',
                      textScaleFactor: 1.5,
                    ),
                  ),
                  Text('from '),
                  Text(ftl.flightDutyPeriod.start.localTimeString,
                      textScaleFactor: 1.5),
                  Text(' to '),
                  Text(ftl.flightDutyPeriod.end.localTimeString,
                      textScaleFactor: 1.5),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'MAXIMUM: ' +
                          durationToStringHM(
                              ftl.flightDutyPeriod.maxFlightDutyPeriodLength),
                      textScaleFactor: 1.5,
                    ),
                  ),
                  Text('till: '),
                  Text(ftl.flightDutyPeriod.maxFlightDutyPeriodEndTime.localTimeString, textScaleFactor: 1.5,)
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'EXTENDED: ' +
                          durationToStringHM(
                              ftl.flightDutyPeriod.extendedFlightDutyPeriodLength),
                      textScaleFactor: 1.5,
                    ),
                  ),
                  Text('till: '),
                  Text(ftl.flightDutyPeriod.extendedFlightDutyPeriodEndTime.localTimeString, textScaleFactor: 1.5,)
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RestPeriodWidget extends StatelessWidget {
  final FTL ftl;

  RestPeriodWidget(this.ftl);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(color: Colors.lightBlueAccent),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'REST PERIOD:',
                  textScaleFactor: 1.5,
                ),
              ),
              Center(
                child: Text(
                  ftl.rest.durationString,
                  textScaleFactor: 1.5,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.lightBlueAccent, width: 3.0),
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      ftl.rest.start.localDayString + ' ',
                      textScaleFactor: 1.5,
                    ),
                  ),
                  Text('from '),
                  Text(ftl.rest.start.localTimeString,
                      textScaleFactor: 1.5),
                  Text(' to '),
                  Text(ftl.rest.end.localTimeString,
                      textScaleFactor: 1.5),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
