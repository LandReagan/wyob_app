import 'package:flutter/material.dart';

import 'package:wyob/objects/Duty.dart' show Duty;
import 'package:wyob/objects/Statistics.dart';
import 'package:wyob/widgets/DutyWidget.dart';


/// Widget containing the ListView of DutyWidgets, built from a List of
/// Duties
class DutiesWidget extends StatelessWidget {

  final List<Duty> duties;
  final List<Statistics> statistics;

  DutiesWidget(this.duties, this.statistics);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: duties == null ?
        Container() :
        ListView.builder(
          itemCount: duties.length,
          itemBuilder: (context, index) {
            Duty current = duties[index];
            Duty previous;
            if (index > 0) {
              previous = duties[index - 1];
              if (!previous.isStandby || !previous.endTime.loc.isAtSameMomentAs(current.startTime.loc)) {
                previous = null;
              }
            }
            DateTime endDayMuscatTime = current.endTime.utc.add(Duration(hours: 4));
            endDayMuscatTime = DateTime(endDayMuscatTime.year, endDayMuscatTime.month, endDayMuscatTime.day);
            Statistics stat = statistics.firstWhere((stat) {
              return stat.day.isAtSameMomentAs(endDayMuscatTime);
            });
            return DutyWidget(current, previous, stat);
          },
        ),
    );
  }
}

