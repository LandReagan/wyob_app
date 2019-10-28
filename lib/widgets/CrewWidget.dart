import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:wyob/data/LocalDatabase.dart';
import 'package:wyob/objects/Crew.dart';
import 'package:wyob/objects/Flight.dart';

class CrewWidget extends StatefulWidget {

  final Flight _flight;

  CrewWidget(this._flight);

  _CrewWidgetState createState() => _CrewWidgetState();
}

class _CrewWidgetState extends State<CrewWidget> {

  Crew _crew;

  Future<void> _getInfo() async {
    // _crew = await LocalDatabase().connector.getCrew(widget._flight);
    setState(() {
      // For tests only
      _crew = getDummyCrew();
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
        Text(member.firstName + " " + member.surname, textScaleFactor: 1.5,),
        Spacer(),
        Text(member.staffNumber, textScaleFactor: 1.5,
          style: TextStyle(fontWeight: FontWeight.bold),),
      ],
    );
  }
  
  Column _generate() {
    
    var crewMembersWidgets = <Widget>[];

    crewMembersWidgets.add( // Upper Row
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
      _crew.crewMembers.where((member) => member.role == "CPT").toList().forEach(
              (captain) => crewMembersWidgets.add(_generateCrewMemberRow(captain))
      );
      _crew.crewMembers.where((member) => member.role == "FO").toList().forEach(
              (firstOfficer) => crewMembersWidgets.add(_generateCrewMemberRow(firstOfficer))
      );
      //todo: CD, PGC, CA, supernumerary, etc...
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
