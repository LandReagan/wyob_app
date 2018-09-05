import 'package:flutter/material.dart';

import '../Duty.dart' show Duty, DutyNature;
import 'WidgetUtils.dart';


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
  Widget icon;
  Text text;
  Text subText;

  DutyWidget(this.duty) {
    icon = WidgetUtils.getIconFromDutyNature(duty.nature);

    // Text building
    String sText = "";
    String sSubText = "";
    sText += duty.startTime.localDayString;
    sText += " ";

    if (duty.nature == "FLIGHT") {
      sText += "Reporting: " + duty.startTime.localTimeString;
      sSubText += duty.startPlace.IATA + ' ';
      sSubText += duty.flights[0].startTime.localTimeString;
      sSubText += '  to  ' + duty.endPlace.IATA + ' ' + duty.endTime.localTimeString;;
    }

    if (duty.nature == "STDBY") {
      sSubText += duty.startTime.localTimeString + ' to ' + duty.endTime.localTimeString;;
    }

    text = new Text(sText);
    subText = new Text(sSubText);
  }

  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(10.0),
      leading: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          icon,
          Text(duty.nature)
        ],
      ),
      title: text,
      subtitle: subText,
      /*new Column(
        children: <Widget>[
          new Text("${duty.startTime.localDayString} ${duty.startPlace.IATA} => ${duty.endPlace.IATA}"),
          new Text('${duty.startTime.localTimeString}'),
        ],
      ),
      */
    );
  }
}