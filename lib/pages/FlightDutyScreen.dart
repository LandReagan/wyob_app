import 'package:flutter/material.dart';

import 'package:wyob/objects/Duty.dart';
import 'package:wyob/objects/Flight.dart';
import 'package:wyob/objects/FTL.dart';
import 'package:wyob/objects/Statistics.dart';
import 'package:wyob/pages/FtlMainPage.dart';
import 'package:wyob/widgets/AccumulatedWidget.dart';
import 'package:wyob/widgets/DurationWidget.dart';
import 'package:wyob/widgets/PeriodWidgets.dart';


class FlightDutyScreen extends StatelessWidget {

  final Duty flightDuty;
  final Duty previous;
  final Statistics statistics;

  FlightDutyScreen(this.flightDuty, this.previous, this.statistics);

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

    List<Widget> widgets = [reportingWidget];

    for (int index = 0; index < flightDuty.flights.length; index++) {
      widgets.add(FlightDutyWidget(flightDuty.flights[index]));
      if (index + 1 < flightDuty.flights.length) { // add a ground time widget
        widgets.add(
          Row(
            children: <Widget>[
              Expanded(
                child: Text('Ground time:', textAlign: TextAlign.right,),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(3.0),
                  child: DurationWidget(
                    flightDuty.flights[index + 1].startTime.difference(
                        flightDuty.flights[index].endTime),
                    textScaleFactor: 1.2,
                    textColor: Colors.amber,
                  ),
                ),
              ),
            ],
          )
        );
      }
    }

    FTL ftl = FTL.fromDuty(flightDuty, previous: previous);

    widgets.add(Divider(color: Colors.white, height: 15.0,));
    widgets.add(FlightDutyPeriodWidget(ftl));
    widgets.add(Divider(color: Colors.white, height: 3.0,));
    widgets.add(DutyPeriodWidget(ftl));
    widgets.add(Divider(color: Colors.white, height: 3.0,));
    widgets.add(RestPeriodWidget(ftl));
    widgets.add(Divider(color: Colors.white, height: 3.0,));
    widgets.add(AccumulatedWidget.fromStatistics(statistics));

    return widgets;
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
