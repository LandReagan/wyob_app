import 'package:flutter/material.dart';

import '../Duty.dart';
import '../Flight.dart';


class FlightDutyScreen extends StatelessWidget {

  final Duty flightDuty;
  String title;

  FlightDutyScreen(this.flightDuty){

    flightDuty.flights.length > 1 ? title = 'Flights: ' : title = 'Flight: ';

    flightDuty.flights.forEach((flight) {
      title += flight.flightNumber + ' ';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: new List<Widget>.generate(
          flightDuty.flights.length,
          (int index) {
            return FlightDutyWidget(flightDuty.flights[index]);
          },
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
    return Row(
      children: <Widget>[
        Container(
          child: Text(_flight.flightNumber),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              Text(_flight.startPlace.IATA + ' => ' + _flight.endPlace.IATA),
              Text("Local:"),
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
              Text("Utc:"),
              Row(
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
            ],
          ),
        ),
      ],
    );
  }

  /*
  @override
  Widget build(BuildContext context) {
    return Row(
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(10.0),
              child: Text(_flight.flightNumber)
          ),
          Column(
            children: <Widget>[
              Text(_flight.startPlace.IATA),
              Text(_flight.startTime.localDayString),
              Text(_flight.startTime.localTimeString),
            ],
          ),
          Container(
              padding: EdgeInsets.all(10.0),
              child: Text("TO"),
          ),
          Column(
            children: <Widget>[
              Text(_flight.endPlace.IATA),
              Text(_flight.endTime.localDayString),
              Text(_flight.endTime.localTimeString),
            ],
          )
        ],
    );
  }
  */
}