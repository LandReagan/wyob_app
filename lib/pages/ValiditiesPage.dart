import 'package:flutter/material.dart';
import 'package:wyob/objects/Validity.dart';
import 'package:wyob/utils/DateTimeUtils.dart';

class ValiditiesPage extends StatelessWidget {

  List<Validity> validities = [
    Validity('Passport', DateTime(2024, 3, 21), amberPeriod: Duration(days: 365)),
    Validity('Visa', DateTime(2022, 3, 15), amberPeriod: Duration(days: 50)),
    Validity('License', DateTime(2020, 1, 1), amberPeriod: Duration(days: 30))
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Validities follow-up'),
      ),
      body: ListView.builder(
        itemCount: validities.length,
        itemBuilder: (context, index) {
          Validity validity = validities[index];
          Color iconColor;
          if (validity.isAmber) {
            iconColor = Colors.amber;
          } else if (validity.isRed) {
            iconColor = Colors.red;
          } else {
            iconColor = Colors.green;
          }
          return ListTile(
            leading: Icon(Icons.access_time, color: iconColor,),
            title: Text(validities[index].name),
            subtitle: Text(dateToString(validities[index].deadline)),
          );
        },
      ),
    );
  }

}