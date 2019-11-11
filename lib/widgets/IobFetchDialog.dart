import 'package:flutter/material.dart';
import 'package:wyob/widgets/FtlDateWidget.dart';

class IobFetchDialog extends StatefulWidget {
  _IobFetchDialogState createState() => _IobFetchDialogState();
}

class _IobFetchDialogState extends State<IobFetchDialog> {
  DateTime from = DateTime.now();
  DateTime to = DateTime.now();

  void fromDateCallback(DateTime date) {
    setState(() {
      this.from = date;
    });
  }

  void toDateCallback(DateTime date) {
    setState(() {
      this.to = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Center(
        child: Text('Fetch duties'),
      ),
      children: <Widget>[
        FtlDateWidget('FROM:', this.from, fromDateCallback),
        FtlDateWidget('TO:', this.to, toDateCallback),
        Row(
          children: <Widget>[
            Expanded(
              child: Center(
                child: SimpleDialogOption(
                  child: Text('CANCEL', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SimpleDialogOption(
                  child: Text('FETCH', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
                  onPressed: () {
                    Map<String, dynamic> data = {
                      'from': this.from,
                      'to': this.to,
                    };
                    Navigator.of(context).pop(data);
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
