import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:wyob/objects/FTL.dart';
import 'package:wyob/widgets/DurationWidget.dart';
import 'package:wyob/widgets/TimeWidgetInline.dart';
import 'package:wyob/widgets/TimeWidgetStack.dart';

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
              DurationWidget(ftl.dutyPeriod.duration)
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
                  TimeWidgetStack(ftl.dutyPeriod.start, 1.5),
                  Icon(Icons.arrow_right),
                  TimeWidgetStack(ftl.dutyPeriod.end, 1.5)
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
              DurationWidget(ftl.flightDutyPeriod.duration)
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
                  TimeWidgetStack(ftl.flightDutyPeriod.start, 1.5),
                  Icon(Icons.arrow_right),
                  TimeWidgetStack(ftl.flightDutyPeriod.end, 1.5)
                ],
              ),
              Divider(color: Colors.white, height: 5,),
              Row(
                children: <Widget>[
                  Expanded(flex: 1, child: Text('MAX: ', textScaleFactor: 1.5,),),
                  Expanded(flex: 3, child: DurationWidget(ftl.flightDutyPeriod.maxFlightDutyPeriodLength),),
                  Icon(Icons.arrow_right),
                  TimeWidgetInline(ftl.flightDutyPeriod.maxFlightDutyPeriodEndTime, 1.5,)
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(flex: 1, child: Text('EXT: ', textScaleFactor: 1.5,),),
                  Expanded(flex: 3, child: DurationWidget(ftl.flightDutyPeriod.extendedFlightDutyPeriodLength),),
                  Icon(Icons.arrow_right),
                  TimeWidgetInline(ftl.flightDutyPeriod.extendedFlightDutyPeriodEndTime, 1.5),
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
              DurationWidget(ftl.rest.duration)
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
                  TimeWidgetStack(ftl.rest.start, 1.5),
                  Icon(Icons.arrow_right),
                  TimeWidgetStack(ftl.rest.end, 1.5)
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
