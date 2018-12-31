import 'package:flutter/material.dart';

import 'package:wyob/objects/Duty.dart';
import 'package:wyob/objects/Flight.dart';


class FlightDutyScreen extends StatelessWidget {

  final Duty flightDuty;
  String title;

  FlightDutyScreen(this.flightDuty){

    flightDuty.flights.length > 1 ? title = 'Flights: ' : title = 'Flight: ';

    flightDuty.flights.forEach((flight) {
      title += flight.flightNumber + ' ';
    });
  }

  List<Widget> getFlightWidgets() {

    Widget reportingWidget = Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.grey,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text("Reporting:", style: TextStyle(fontStyle: FontStyle.italic),),
          ),
          Expanded(
            child: Text(
              flightDuty.startTime.localDayString,
              style: TextStyle(color: Colors.red),
            ),
          ),
  
          Expanded(
            child: Text(
              flightDuty.startTime.localTimeString,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    List<Widget> flightWidgets =  List<Widget>.generate(
      flightDuty.flights.length,
      (int index) {
        return FlightDutyWidget(flightDuty.flights[index]);
      },
    );

    List<Widget> result = [reportingWidget];

    for (Widget flightWidget in flightWidgets) {
      result.add(Divider(
        height: 5.0,
        color: Colors.black,
      ));
      result.add(flightWidget);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: DefaultTextStyle(
        style: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.bold
        ),
        child: Column(
          children: getFlightWidgets(),
        ),
      ),
    );
  }
}


class FlightDutyWidget extends StatelessWidget {

  final Flight _flight;

  FlightDutyWidget(this._flight);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(5.0),
            child: Text(_flight.flightNumber, textAlign: TextAlign.center,),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(_flight.startPlace.IATA, textAlign: TextAlign.center,),
                    ),
                    Expanded(
                      child: Text(_flight.endPlace.IATA, textAlign: TextAlign.center,),
                    )
                  ]
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text(_flight.startTime.localDayString),
                          Text(_flight.startTime.localTimeString),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text(_flight.endTime.localDayString),
                          Text(_flight.endTime.localTimeString),
                        ],
                      ),
                    ),
                  ],
                ),
                // UTC Row
                DefaultTextStyle(
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.italic,
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Text(_flight.startTime.utcDayString),
                            Text(_flight.startTime.utcTimeString),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Text(_flight.endTime.utcDayString),
                            Text(_flight.endTime.utcTimeString),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}