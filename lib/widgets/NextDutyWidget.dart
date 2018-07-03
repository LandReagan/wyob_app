import 'package:flutter/material.dart';

/// This widget occupies the Upper part of the duties view
class NextDutyWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Expanded(
      flex: 3,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new NextDutyTopWidget(),
          new NextDutyBottomWidget(),
        ],
      ),
    );
  }
}


class NextDutyTopWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        /*
        new Container(
          child: new Text("DUTY LOGO\nDUTY LOGO\nDUTY LOGO\nDUTY LOGO"),
          color: Colors.lightBlueAccent,
        ),
        */
        new Expanded(
          child: new Container(
            color: Colors.blue,
            child: new Text("DUTY DESCRIPTION"),
          ),
        ),
      ],
    );
  }
}


class NextDutyBottomWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Expanded(
          child:new Center(child: new Text("DATE")),
        ),
        new Expanded(
          child: new Center(child: new Text("START")),
        ),
        new Expanded(
          child: new Center(child: new Text("END")),
        ),
      ],
    );
  }
}
