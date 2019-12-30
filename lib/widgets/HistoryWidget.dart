import 'package:flutter/material.dart';
import 'package:wyob/data/LocalDatabase.dart';
import 'package:wyob/widgets/HistoryMonthWidget.dart';

class HistoryWidget extends StatefulWidget {
  _HistoryWidgetState createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {

  List<HistoryMonthWidget> _widgets = [];

  @override
  void initState() {
    super.initState();
    LocalDatabase().notifier.addListener(this.refresh);
    refresh();
  }

  void refresh() {
    _widgets.clear();
    LocalDatabase().getAllMonthlyAggregations().forEach((aggregation) {
      _widgets.add(HistoryMonthWidget(aggregation));
    });
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _widgets.length,
      itemBuilder: (context, index) {
        return _widgets[index];
      },
    );
  }

}