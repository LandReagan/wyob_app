import 'package:flutter/material.dart';
import 'package:wyob/objects/Statistics.dart';
import 'package:wyob/widgets/DurationWidget.dart';

class AccumulatedWidget extends StatelessWidget {

  final Duration duty7Days;
  final Duration duty28Days;
  final Duration duty365Days;

  final Duration block28Days;
  final Duration block365Days;

  final bool sevenDaysCompleteness;
  final bool twentyEightDaysCompleteness;
  final bool oneYearCompleteness;

  AccumulatedWidget.fromStatistics(Statistics statistics) :
      this.duty7Days = statistics.sevenDaysDutyAccumulation,
      this.duty28Days = statistics.twentyEightDaysDutyAccumulation,
      this.duty365Days = statistics.oneYearDutyDaysAccumulation,
      this.block28Days = statistics.twentyEightDaysBlockAccumulation,
      this.block365Days = statistics.oneYearBlockAccumulation,
      this.sevenDaysCompleteness = statistics.sevenDaysDutyCompleteness,
      this.twentyEightDaysCompleteness = statistics.twentyEightDaysDutyCompleteness,
      this.oneYearCompleteness = statistics.oneYearDutyDaysCompleteness;

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
                        Text('7 :', textScaleFactor: 1.5,
                          style: !sevenDaysCompleteness ?
                            TextStyle(decoration: TextDecoration.lineThrough) : null,),
                        DurationWidget(duty7Days),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Text('28 :', textScaleFactor: 1.5,
                          style: !twentyEightDaysCompleteness ?
                            TextStyle(decoration: TextDecoration.lineThrough) : null,),
                        DurationWidget(duty28Days),
                      ],
                    ),
                  ),
                  Text('365: ', textScaleFactor: 1.5,
                    style: !oneYearCompleteness ?
                      TextStyle(decoration: TextDecoration.lineThrough) : null,),
                  DurationWidget(duty365Days)
                ],
              ),
              Text('BLOCK (last X days)', textScaleFactor: 1.5,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: IconButton(
                      icon: Icon(Icons.help),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AccumulatedAlertHelp()
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Text('28 :', textScaleFactor: 1.5,
                          style: !twentyEightDaysCompleteness ?
                            TextStyle(decoration: TextDecoration.lineThrough) : null,),
                        DurationWidget(block28Days),
                      ],
                    ),
                  ),
                  Text('365: ', textScaleFactor: 1.5,
                    style: !oneYearCompleteness ?
                      TextStyle(decoration: TextDecoration.lineThrough) : null,),
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

class AccumulatedAlertHelp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text("Accumulated times"),),
      content: Text("Accumulated times are calculated according to OM-A ch.7, "
          "based on MCT local day definition.\nIf the number of days has a "
          "line through, go to database and fetch missing duties."),
      actions: <Widget>[
        FlatButton(
          child: Text("OK"),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }
}
