import 'package:flutter/material.dart';
import 'package:wyob/objects/Duty.dart';
import 'package:wyob/objects/FTL.dart';
import 'package:wyob/widgets/FtlDateWidget.dart';
import 'package:wyob/widgets/FtlTimeWidget.dart';

class FtlMainPage extends StatefulWidget {

  FTL ftl;

  FtlMainPage(Duty duty) : ftl = FTL(duty);

  _FtlMainPageState createState() => _FtlMainPageState();
}

class _FtlMainPageState extends State<FtlMainPage> {

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FTL calculator'),
      ),
      body: FtlMainWidget(widget.ftl),
    );
  }
}

class FtlMainWidget extends StatefulWidget {

  final FTL ftl;

  FtlMainWidget(this.ftl);

  _FtlMainWidgetState createState() => _FtlMainWidgetState();
}

/// This class draws the page and interacts with the FTL object to get
/// information.
class _FtlMainWidgetState extends State<FtlMainWidget> {



  List<ListTile> _getInputDataWidgets() {
    List<ListTile> inputDataWidgets = <ListTile>[];

    // Date and reporting
    inputDataWidgets.add(
      ListTile(title: Row(children: <Widget>[
        Expanded(
          child: FtlDateWidget('Reporting date', null)
        ),
        Expanded(
          child: FtlTimeWidget('Reporting time'),
        ),
      ],),)
    );

    return inputDataWidgets;
  }

  Widget build(BuildContext context) {

    List<ListTile> tiles = [];
    tiles.addAll(_getInputDataWidgets());

    return ListView(
      children: tiles,
    );
  }
}

