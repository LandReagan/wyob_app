import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FtlMainPage extends StatefulWidget {
  _FtlMainPageState createState() => _FtlMainPageState();
}

class _FtlMainPageState extends State<FtlMainPage> {

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FTL calculator'),
      ),
      body: FtlMainWidget(),
    );
  }
}

class FtlMainWidget extends StatefulWidget {
  _FtlMainWidgetState createState() => _FtlMainWidgetState();
}

/// This class draws the page and interacts with the FTL object to get
/// information.
class _FtlMainWidgetState extends State<FtlMainWidget> {

  DateTime reporting;
  DateTime onBlocks;

  List<ListTile> _getInputDataWidgets() {
    List<ListTile> inputDataWidgets = <ListTile>[];

    // TITLE
    inputDataWidgets.add(
      ListTile(title: Text('INPUTS'),)
    );

    // Date and reporting
    inputDataWidgets.add(
      ListTile(title: Row(children: <Widget>[
        Text('DATE'),
        Expanded(child: TextField(),),
        Text('REPORTING:'),
        Expanded(child: TextField(),)
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

