import 'package:flutter/material.dart';
import 'package:wyob/data/LocalDatabase.dart';
import 'package:wyob/widgets/HistoryWidget.dart';
import 'package:wyob/widgets/IobFetchDialog.dart';
import 'package:wyob/widgets/IobStateWidget.dart';

class HistoryPage extends StatefulWidget {
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

  void fetch(Map<String, dynamic> data) async {
    await LocalDatabase().updateFromGantt(
        fromParameter: data['from'], toParameter: data['to']);
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () async {
              Map<String, dynamic> data = await showDialog(
                context: context,
                builder: (context) {
                  return IobFetchDialog();
              });
              fetch(data);
            },
          ),
        ],
      ),
      body: HistoryWidget(),
      bottomNavigationBar: IobStateWidget(null),
    );
  }
}