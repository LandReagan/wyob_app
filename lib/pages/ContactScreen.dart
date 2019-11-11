import 'package:flutter/material.dart';


class ContactScreen extends StatelessWidget {

  final Map<String, dynamic> details;

  final List<String> detailsKeys = [
    "Name",
    "Title",
    "Phone",
    "Phone 2",
    "Phone 3",
    "Phone 3",
    "Mobile",
    "Mobile 2",
    "Email",
  ];

  ContactScreen(this.details);

  Icon _getLeadingIcon(String key) {
    if (key.contains("Phone")) {
      return Icon(Icons.phone);
    } else if (key.contains("Mobile")) {
      return Icon(Icons.phone_iphone);
    } else if (key.contains("E-mail")) {
      return Icon(Icons.email);
    } else {
      return Icon(Icons.account_box);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(details['Name']),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          if (details.containsKey(detailsKeys[index])) {
            return ListTile(
              leading: _getLeadingIcon(detailsKeys[index]),
              title: Text(detailsKeys[index] + ": " + details[detailsKeys[index]]),
            );
          }
        },
      ),
    );
  }
}