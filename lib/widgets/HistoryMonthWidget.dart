import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:wyob/objects/MonthlyAggregation.dart';
import 'package:wyob/pages/MonthDutyPage.dart';
import 'package:wyob/utils/DateTimeUtils.dart';

class HistoryMonthWidget extends StatelessWidget {

  final MonthlyAggregation _aggregation;

  HistoryMonthWidget(this._aggregation);

  String get _monthTitle {
    return getMonthFullString(_aggregation.monthStart.month) + ' '
        + _aggregation.monthStart.year.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MonthDutyPage(_monthTitle, _aggregation)
          )
        );
      },
      child: ListTile(
        title: Text(_monthTitle, textScaleFactor: 1.5, textAlign: TextAlign.center,),
        trailing: Icon(Icons.chevron_right)
      ),
    );
  }

}