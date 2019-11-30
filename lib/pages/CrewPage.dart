import 'package:flutter/material.dart';
import 'package:wyob/widgets/CrewWidget.dart';

class CrewPage extends StatefulWidget{
  _CrewPageState createState() => _CrewPageState();
}

class _CrewPageState extends State<CrewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crew Checker"),
      ),
      body: CrewWidget(null),
    );
  }
}