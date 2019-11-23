import 'package:flutter/material.dart';
import 'package:wyob/data/LocalDatabase.dart';

class DebugPage extends StatefulWidget {
  _DebugPageState createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Debug tools"),
      ),
      body: ListView(
        children: <Widget>[
          _ToggleAutoFetch(),
        ],
      ),
    );
  }
}

class _ToggleAutoFetch extends StatefulWidget {
  _ToggleAutoFetchState createState() => _ToggleAutoFetchState();
}

class _ToggleAutoFetchState extends State<_ToggleAutoFetch> {

  bool value;

  @override
  void initState() {
    super.initState();
    value = LocalDatabase().getAutoFetchOnStartUp();
  }

  void _toggleValue(bool newValue) async {
    await LocalDatabase().setAutoFetchOnStartUp(newValue);
    setState(() {
      value = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListTile(
      title: Text("Toggle auto-fetching current duties on start-up"),
      trailing: Switch(
        value: this.value,
        onChanged: (newValue) => _toggleValue(newValue),
      ),
    );
  }
}
