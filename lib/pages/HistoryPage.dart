import 'package:flutter/material.dart';
import 'package:wyob/widgets/HistoryWidget.dart';
import 'package:wyob/widgets/IobFetchDialog.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () {
              showDialog(context: context, builder: (context) {
                return IobFetchDialog();
              });
            },
          ),
        ],
      ),
      body: HistoryWidget(),
    );
  }
}