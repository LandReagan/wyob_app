import 'package:flutter/material.dart';
import 'package:wyob/objects/Statistics.dart';
import 'package:wyob/widgets/DurationWidget.dart';

class AccumulatedWidget extends StatelessWidget {

  final Duration duty7Days;
  final Duration duty28Days;
  final Duration duty365Days;

  final Duration block28Days;
  final Duration block365Days;

  AccumulatedWidget(
      this.duty7Days,
      this.duty28Days,
      this.duty365Days,
      this.block28Days,
      this.block365Days);

  AccumulatedWidget.fromStatistics(Statistics statistics) :
      this.duty7Days = statistics.sevenDaysDutyAccumulation,
      this.duty28Days = statistics.twentyEightDaysDutyAccumulation,
      this.duty365Days = statistics.oneYearDutyDaysAccumulation,
      this.block28Days = statistics.twentyEightDaysBlockAccumulation,
      this.block365Days = statistics.oneYearBlockAccumulation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(color: Colors.purpleAccent),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'ACCUMULATED TIMES:',
                  textScaleFactor: 1.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.purpleAccent, width: 3.0),
          ),
          child: Column(
            children: <Widget>[
              Text('DUTY (last X days)', textScaleFactor: 1.5,),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Text('7 :', textScaleFactor: 1.5,),
                        DurationWidget(duty7Days),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Text('28 :', textScaleFactor: 1.5,),
                        DurationWidget(duty28Days),
                      ],
                    ),
                  ),
                  Text('365: ', textScaleFactor: 1.5,),
                  DurationWidget(duty365Days)
                ],
              ),
              Text('BLOCK (last X days)', textScaleFactor: 1.5,),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Text('28 :', textScaleFactor: 1.5,),
                        DurationWidget(block28Days),
                      ],
                    ),
                  ),
                  Text('365: ', textScaleFactor: 1.5,),
                  DurationWidget(block365Days)
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
