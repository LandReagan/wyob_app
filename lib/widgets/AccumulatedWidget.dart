import 'package:flutter/material.dart';
import 'package:wyob/objects/Statistics.dart';

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
    // TODO: implement build
    return null;
  }
}
