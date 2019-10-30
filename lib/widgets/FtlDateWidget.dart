import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class FtlDateWidget extends StatefulWidget {

  final String title;
  final DateTime initialDate;
  final ValueChanged<DateTime> callback;

  FtlDateWidget(this.title, this.initialDate, this.callback);

  _FtlDateWidgetState createState() => _FtlDateWidgetState();
}

class _FtlDateWidgetState extends State<FtlDateWidget> {

  DateTime _date;

  void initState() {
    super.initState();
    _date = widget.initialDate;
  }

  String get dateString {
    if (_date == null) {
      return 'Tap here';
    } else {
      return DateFormat('ddMMMy').format(_date);
    }
  }

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5.0),
      child: Column(
        children: <Widget>[
          Text(widget.title, style: TextStyle(fontStyle: FontStyle.italic),),
          GestureDetector(
            child: Text(dateString, textScaleFactor: 1.2,),
            onTap: () async {
              _date = await showDatePicker(
                context: context,
                firstDate: DateTime(1993),
                initialDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 60))
              );
              widget.callback(_date);
            }
          )
        ],
      ),
    );
  }
}
