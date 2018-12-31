/*
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'ContactScreen.dart';


class DirectoryPage extends StatelessWidget {


  Widget _buildContactItem(BuildContext context, DocumentSnapshot document) {

    Map<String, dynamic> contactDetails = document.data;

    return ListTile(
      leading: Icon(Icons.account_box),
      title: Text(document['Name']),
      trailing: IconButton(
        icon: Icon(Icons.arrow_forward),
        onPressed: () => _goToContactDetails(context, contactDetails),
      ),
    );
  }
  
  void _goToContactDetails(BuildContext context, Map<String, dynamic> details) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ContactScreen(details);
        }
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          child: Icon(Icons.arrow_back),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        title: new Text("WY Directory"),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('ContactInfos').snapshots(),
        builder: (context, snapshot){
          if (!snapshot.hasData) return const Text("Loading...");
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              return _buildContactItem(context, snapshot.data.documents[index]);
            },
          );
        },
      ),
    );
  }
}
*/