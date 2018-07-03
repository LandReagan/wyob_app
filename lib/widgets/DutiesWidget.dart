import 'package:flutter/material.dart';

import '../Duty.dart' show Duty, DutyNature;


class DutiesWidget extends StatelessWidget {

  List<Duty> duties;

  DutiesWidget(this.duties);

  @override
  Widget build(BuildContext context) {
    return new Expanded(
      flex: 7,
      child: duties == null ? new Container() : new ListView.builder(
        itemCount: duties.length,
        itemBuilder: (context, index) {
          return DutyWidget(duties[index]);
        }
      )
    );
  }
}

class DutyWidget extends StatelessWidget {

  Duty duty;
  Icon icon;

  DutyWidget(this.duty) {
    if (duty.nature == 'FLIGHT') {
      icon = new Icon(Icons.flight);
    } else {
      icon = new Icon(Icons.schedule);
    }
  }

  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,
      title: new Column(
        children: <Widget>[
          new Text("${duty.startTime.localDayString} ${duty.startPlace.IATA} => ${duty.endPlace.IATA}"),
          new Text('${duty.startTime.localTimeString}'),
        ],
      ),
    );
  }
}