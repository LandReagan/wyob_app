import 'package:flutter/material.dart';

import 'package:wyob/objects/Duty.dart';
import 'package:wyob/objects/Flight.dart';
import 'package:wyob/objects/Rest.dart';


class FlightDutyScreen extends StatelessWidget {

  final Duty flightDuty;
  final Rest rest;

  FlightDutyScreen(this.flightDuty) : rest = Rest.fromDuty(flightDuty);

  String getTitle() {
    String returnValue = '';
    flightDuty.flights.length > 1 ? returnValue = 'Flights: ' : returnValue = 'Flight: ';

    flightDuty.flights.forEach((flight) {
      returnValue += flight.flightNumber + ' ';
    });
    return returnValue;
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
      result.add(flightWidget);
      result.add(Divider(
        height: 5.0,
        color: Colors.black,
      ));
    }

    result.add(RestWidget(rest));

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTitle()),
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

class RestWidget extends StatelessWidget {

  final Rest _rest;

  RestWidget(this._rest);

  String getMinimumRestDuration() {
    int hours = _rest.duration.inHours;
    int minutes = _rest.duration.inMinutes - hours * 60;
    return hours.toString() + 'h' + (
        minutes.toString() == '0' ? '' : minutes.toString() + 'm'
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        color: Colors.black,
        fontSize: 20.0,
        fontWeight: FontWeight.normal
      ),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Icon(Icons.hotel, size: 40.0,),
          ),
          Expanded(
              child: Column(
                children: <Widget>[
                  Text('Minimum rest: ' + getMinimumRestDuration(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),),
                  Text('ends: ' + _rest.endTime.localDayString + ' ' +
                      _rest.endTime.localTimeString,
                    style: TextStyle(color: Colors.redAccent),
                  )
                ],
              )
          )
        ],
      ),
    );
  }
}

class FlightDutyWidget extends StatelessWidget {

  final Flight _flight;

  final TextStyle bigBoldStyle = TextStyle(
    color: Colors.black,
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
  );

  final TextStyle bigNormalStyle = TextStyle(
    color: Colors.black,
    fontSize: 20.0,
    fontWeight: FontWeight.normal,
  );

  final TextStyle bigBlueItalicStyle = TextStyle(
    color: Colors.blue,
    fontSize: 20.0,
    fontWeight: FontWeight.normal,
    fontStyle: FontStyle.italic
  );

  final TextStyle smallNormalStyle = TextStyle(
    color: Colors.black,
    fontSize: 15.0,
    fontWeight: FontWeight.normal,
  );

  FlightDutyWidget(this._flight);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Row(
        children: <Widget>[

          // First column, Flight number - Local date - UTC date if different
          Column(
            children: <Widget>[
              Text(_flight.flightNumber, textAlign: TextAlign.center,
                  style: bigBoldStyle,),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(_flight.startTime.localDayString, style: bigNormalStyle,),
              ),
              Padding(padding: EdgeInsets.all(5.0),
                child: Text(
                  _flight.startTime.utcDayString == _flight.startTime.localDayString ? '' : _flight.startTime.utcDayString,
                  style: bigBlueItalicStyle,),
              ),
            ],
          ),

          // Second column, IATA Departure - DEP time loc - DEP time UTC
          Expanded(
            child: Column(
              children: <Widget>[
                Text(_flight.startPlace.IATA, style: bigBoldStyle,),
                Container(
                  padding: EdgeInsets.all(5.0),
                  child: Column(
                    children: <Widget>[
                      Text(_flight.startTime.localTimeString,
                          style: bigNormalStyle,),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5.0),
                  child: Column(
                    children: <Widget>[
                      Text(_flight.startTime.utcTimeString,
                          style: bigBlueItalicStyle,),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Third column IATA DEST - ARR time local - ARR time UTC
          Expanded(
            child: Column(
              children: <Widget>[
                Text(_flight.endPlace.IATA, style: bigBoldStyle,),
                Container(
                  padding: EdgeInsets.all(5.0),
                  child: Column(
                    children: <Widget>[
                      Text(_flight.endTime.localTimeString,
                        style: bigNormalStyle,),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5.0),
                  child: Column(
                    children: <Widget>[
                      Text(_flight.endTime.utcTimeString,
                        style: bigBlueItalicStyle,),
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
