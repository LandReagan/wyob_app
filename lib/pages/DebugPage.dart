import 'package:flutter/material.dart';

import 'package:wyob/data/LocalDatabase.dart';
import 'package:wyob/widgets/DatabaseContentWidget.dart';

class DatabasePage extends StatelessWidget {

  final LocalDatabase database = LocalDatabase();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Database'),
      ),
      body: DatabaseContentWidget(database.getDutiesAll()),
    );
  }
}
