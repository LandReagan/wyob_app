import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wyob/utils/DateTimeUtils.dart';

class GMTDiffWidget extends StatefulWidget {

  final String title;
  final Duration initialGMTDiff;
  final ValueChanged<Duration> callback;

  GMTDiffWidget(this.title, this.initialGMTDiff, this.callback);

  _GMTDiffWidgetState createState() => _GMTDiffWidgetState();
}

class _GMTDiffWidgetState extends State<GMTDiffWidget> {

  Duration _gmtDiff;

  void initState() {
    super .initState();
    if (widget.initialGMTDiff != null) {
      _gmtDiff = widget?.initialGMTDiff;
    } else {
      _gmtDiff = Duration.zero;
    }

  }

  String get gmtDiffString => durationToStringHM(_gmtDiff);

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5.0),
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Text(widget.title, style: TextStyle(fontStyle: FontStyle.italic),),
              Text(gmtDiffString, textScaleFactor: 1.2,),
            ],
          ),
          Column(
            children: <Widget>[
              FlatButton(
                child: Text('+', textScaleFactor: 1.5,),
                  onPressed: () {
                    setState(() {
                      _gmtDiff += Duration(minutes: 15);
                    });
                    widget.callback(_gmtDiff);
                  },
              ),
              FlatButton(
                child: Text('-', textScaleFactor: 1.5,),
                  onPressed: () {
                    setState(() {
                      _gmtDiff -= Duration(minutes: 15);
                    });
                    widget.callback(_gmtDiff);
                  },
              )
            ],
          ),
        ],
      )
    );
  }
}
