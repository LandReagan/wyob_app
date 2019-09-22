import 'package:flutter/material.dart';

import 'package:wyob/objects/Duty.dart';
import 'package:wyob/objects/Flight.dart';
import 'package:wyob/objects/FTL.dart';
import 'package:wyob/pages/FtlMainPage.dart';
import 'package:wyob/widgets/DurationWidget.dart';
import 'package:wyob/widgets/PeriodWidgets.dart';


class FlightDutyScreen extends StatelessWidget {

  final Duty flightDuty;
  final Duty previous;

  FlightDutyScreen(this.flightDuty, this.previous);

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
        color: Color.fromRGBO(220, 220, 220, 1.0),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text("Reporting:", style: TextStyle(fontStyle: FontStyle.italic),textScaleFactor: 1.5,),
          ),
          Expanded(
            child: Text(
              flightDuty.startTime.localDayString + ' ',textScaleFactor: 1.5,
              style: TextStyle(color: Colors.red),
            ),
          ),
       Text(
            flightDuty.startTime.localTimeString,textScaleFactor: 1.5,
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
    }

    FTL ftl = FTL.fromDuty(flightDuty, previous: previous);

    result.add(Divider(color: Colors.white, height: 15.0,));
    result.add(FlightDutyPeriodWidget(ftl));
    result.add(Divider(color: Colors.white, height: 3.0,));
    result.add(DutyPeriodWidget(ftl));
    result.add(Divider(color: Colors.white, height: 3.0,));
    result.add(RestPeriodWidget(ftl));

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTitle()),
        actions: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            child: OutlineButton(
              child: Text('FTL >'),
              textColor: Colors.white,
              borderSide: BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
              onPressed: () {
                return Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FtlMainPage(flightDuty, previous)
                  )
                );
              },
            ),
          ),
        ],
      ),
      body: ListView(
          children: getFlightWidgets(),
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

          // Fourth column with block time
          Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Text("BLOCK:"),
              ),
              DurationWidget(_flight.duration)
            ],
          )
        ],
      ),
    );
  }
}
