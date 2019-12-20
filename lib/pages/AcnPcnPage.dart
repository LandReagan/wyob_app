import 'package:flutter/material.dart';
import 'package:wyob/widgets/AcnPcnWidget.dart';

class AcnPcnPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ACN PCN calculator'),
      ),
      body: AcnPcnWidget(),
    );
  }
}