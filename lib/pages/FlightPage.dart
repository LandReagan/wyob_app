import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wyob/objects/Crew.dart';
import 'package:wyob/objects/Flight.dart';
import 'package:wyob/widgets/CrewWidget.dart';

class FlightPage extends StatefulWidget {

  final Flight _flight;

  FlightPage(this._flight);

  _FlightPageState createState() => _FlightPageState();

}

class _FlightPageState extends State<FlightPage> {

  List<Widget> _getWidgets() {
    var widgets = <Widget>[];

    // Crew data:
    widgets.add(CrewWidget(widget._flight));

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._flight.flightNumber),
      ),
      body: ListView(children: _getWidgets()),
    );
  }
}
