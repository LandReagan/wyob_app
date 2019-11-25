import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:logger/logger.dart';
import 'package:wyob/WyobException.dart';
import 'package:wyob/data/LocalDatabase.dart';
import 'package:wyob/objects/Crew.dart';
import 'package:wyob/objects/Flight.dart';
import 'package:wyob/utils/Parsers.dart';
import 'package:wyob/widgets/FltNumberWidget.dart';

import 'FtlDateWidget.dart';

class CrewWidget extends StatefulWidget {

  final Flight _flight;

  CrewWidget(this._flight);

  _CrewWidgetState createState() => _CrewWidgetState();
}

class _CrewWidgetState extends State<CrewWidget> {

  Crew _crew;
  bool offline = false;
  bool fetching = false;

  DateTime date;
  String flightNumber;

  void initState() {
    super.initState();
    if (widget._flight != null) {
      date = widget._flight.startTime.loc;
      flightNumber = widget._flight.flightNumber;
    }
  }

  void changeFlightNumber(String newValue) {
    flightNumber = newValue;
  }

  void changeDate(DateTime newDate) {
    setState(() {
      date = newDate;
    });
  }

  Future<void> _getInfo() async {

    setState(() {
      fetching = true;
    });

    String crewData;
    try {
      crewData = await LocalDatabase().connector.getCrew(
          date,
          flightNumber
      );
    } on WyobExceptionOffline {
      _crew = null;
      offline = true;
      return;
    } on WyobExceptionParser {
      _crew = null;
      Logger().w("Crew parsing problem!");
    } on WyobException catch (e) {
      Logger().w("Unexpected exception thrown: " + e.toString());
    }

    setState(() {
      fetching = false;
      try {
        _crew = Crew.fromParser(parseCrewPage(crewData));
      } on WyobExceptionParser catch (e) {
        Logger().w("Error while parsing crew: " + e.toString());
      }
    });
  }

  Row _generateCrewMemberRow(CrewMember member) {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(5.0),
          child: Text(member.rank, textScaleFactor: 1.5,
            style: TextStyle(fontWeight: FontWeight.bold),),
        ),
        Expanded(
          child: Text(
            member.firstName + " " + member.surname,
            textScaleFactor: 1.5,
            textAlign: TextAlign.center,
          ),
        ),
        Text(member.staffNumber, textScaleFactor: 1.5,
          style: TextStyle(fontWeight: FontWeight.bold),),
      ],
    );
  }
  
  Column _generate() {
    
    var crewMembersWidgets = <Widget>[];

    crewMembersWidgets.add(
      Row(
        children: <Widget>[
          Expanded(
            child: FtlDateWidget("Date", date, this.changeDate),
          ),
          Expanded(
            child: FltNumberWidget("Flt Num", flightNumber, this.changeFlightNumber),
          )
        ],
      ),
    );

    crewMembersWidgets.add( // Middle Row
      Row(
        children: <Widget>[
          Expanded(
            child: Text("Crew:", textScaleFactor: 1.5, textAlign: TextAlign.center,),
          ),
          FlatButton(
            child: Text("Get info", textScaleFactor: 1.5 ,),
            padding: EdgeInsets.all(5.0),
            color: Colors.blueGrey,
            onPressed: () => _getInfo(),
          )
        ],
      ),
    );

    if (_crew != null) {
      _crew.crewMembers.where((member) => member.rank == "CAPT").toList().forEach(
              (cpt) => crewMembersWidgets.add(_generateCrewMemberRow(cpt))
      );
      _crew.crewMembers.where((member) => member.rank == "FO").toList().forEach(
              (fo) => crewMembersWidgets.add(_generateCrewMemberRow(fo))
      );
      _crew.crewMembers.where((member) => member.role == "CD").toList().forEach(
              (cd) => crewMembersWidgets.add(_generateCrewMemberRow(cd))
      );
      _crew.crewMembers.where((member) => member.role == "PGC").toList().forEach(
              (pgc) => crewMembersWidgets.add(_generateCrewMemberRow(pgc))
      );
      _crew.crewMembers.where((member) => member.role == "CA").toList().forEach(
              (ca) => crewMembersWidgets.add(_generateCrewMemberRow(ca))
      );
      //todo: any other? Supernumerary?
    } else {
      if (fetching) {
        crewMembersWidgets.add(
            Row(
              children: <Widget>[
                Expanded(
                  child: Text("FETCHING...",
                    textScaleFactor: 1.5, textAlign: TextAlign.center,),
                )
              ],
            )
        );
      } else {
        crewMembersWidgets.add(
            Row(
              children: <Widget>[
                Expanded(
                  child: Text("NO INFORMATION",
                    textScaleFactor: 1.5, textAlign: TextAlign.center,),
                )
              ],
            )
        );
      }
    }
    
    return Column (
      children: crewMembersWidgets
    );
  }

  @override
  Widget build(BuildContext context) {
    return _generate();
  }
}

