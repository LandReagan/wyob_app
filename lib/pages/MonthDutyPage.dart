import 'package:flutter/material.dart';
import 'package:wyob/objects/Duty.dart';
import 'package:wyob/objects/MonthlyAggregation.dart';
import 'package:wyob/objects/Statistics.dart';
import 'package:wyob/widgets/DutyWidget.dart';

class MonthDutyPage extends StatelessWidget {

  final String _title;
  final int _itemCount;
  final MonthlyAggregation _aggregation;

  MonthDutyPage(this._title, this._aggregation) : _itemCount = _aggregation.dutiesAndStatistics.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: ListView.builder(
        itemCount: _itemCount,
        itemBuilder: (context, index) {
          Duty current = _aggregation.dutiesAndStatistics[index]['duty'];
          Duty previous;
          if (index > 0) {
            previous = _aggregation.dutiesAndStatistics[index - 1]['duty'];
          }
          Statistics statistics = _aggregation.dutiesAndStatistics[index]['stat'];
          return DutyWidget(current, previous, statistics, true);
        },
      ),
    );
  }
}