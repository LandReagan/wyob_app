import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:wyob/objects/Duty.dart';

class DatabaseContentWidget extends StatelessWidget {

  final List<Duty> _duties;

  DatabaseContentWidget(this._duties);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _duties.length,
      itemBuilder: (context, index) => RawDutyWidget(_duties[index]),
    );
  }
}

class RawDutyWidget extends StatelessWidget {

  final Duty duty;

  static const BOLD = TextStyle(fontWeight: FontWeight.bold);
  static const ITALIC = TextStyle(fontStyle: FontStyle.italic);

  static const PALE_GREY = Color.fromRGBO(230, 230, 230, 1.0);

  RawDutyWidget(this.duty);

  Widget getStartDateWidget() {

    var widgets = <Widget>[];
    widgets.add(Expanded(child: Text(duty.startTime.localDayString)));
    if (duty.nature == 'FLIGHT' || duty.nature == 'GROUND' || duty.nature == 'SIM') {
      widgets.add(Text('REPORTING: '));
      widgets.add(Expanded(child: Text(duty.startTime.localTimeString, style: BOLD,)));
    }

    return Row(
      children: widgets
    );
  }

  Widget getEndDateWidget() {

    var widgets = <Widget>[];
    if (duty.startTime.localDayString != duty.endTime.localDayString) {
      widgets.add(Expanded(child: Text(duty.endTime.localDayString),),);
    } else {
      widgets.add(Expanded(child: Text(''),));
    }

    if (duty.nature == 'FLIGHT' || duty.nature == 'GROUND' || duty.nature == 'SIM') {
      widgets.add(Text('OFF DUTY: '));
      widgets.add(
          Expanded(child: Text(duty.endTime.localTimeString, style: BOLD,)));
    }

    return Row(
      children: widgets,
    );
  }

  Widget getHeaderWidget() {
    return Row(
      children: <Widget>[
        Expanded(child: Text(duty.nature ?? '', style: BOLD,),),
        Text('CODE: '),
        Expanded(child: Text(duty.code ?? '---', style: BOLD,),),
        Text('STATUS: '),
        Expanded(child: Text(duty.statusAsString ?? '', style: BOLD,),),
      ],
    );
  }

  List<Widget> getFlightsWidgets() {
    List<Widget> flightWidgets = [];
    duty.flights.forEach((flight) {
      flightWidgets.add(
        Container(
          decoration: BoxDecoration(
            color: PALE_GREY
          ),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(flight.flightNumber ?? '', style: BOLD,),),
              Text(flight.startPlace.IATA + ' ', style: BOLD,),
              Text(flight.startTime.localTimeString + ' ', style: BOLD),
              Expanded(child: Text(flight.startTime.utcTimeString, style: ITALIC),),
              Text(flight.endPlace.IATA + ' ', style: BOLD,),
              Text(flight.endTime.localTimeString + ' ', style: BOLD,),
              Expanded(child: Text(flight.endTime.utcTimeString, style: ITALIC,),),
              Text(flight.durationString, style: BOLD,),
            ],
          ),
        )
      );
    });
    return flightWidgets;
  }

  Widget getStandByWidget() {
    return Row(
      children: <Widget>[
        Text('from:', style: ITALIC,),
        Expanded(child: Text(duty.startTime.localTimeString, style: BOLD,),),
        Text('to:', style: ITALIC,),
        Expanded(child: Text(duty.endTime.localTimeString, style: BOLD,),),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> widgets = [];
    widgets.add(getStartDateWidget());
    widgets.add(getHeaderWidget());
    widgets.addAll(getFlightsWidgets());
    if (duty.nature == 'STDBY') widgets.add(getStandByWidget());
    if (getEndDateWidget() != null) widgets.add(getEndDateWidget());
    widgets.add(Divider(color: Colors.black,));

    return Container(
      padding: EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        //todo
      ),
      child: Column(
        children: widgets
      ),
    );
  }
}
