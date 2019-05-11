
import 'package:flutter/material.dart';

import 'package:wyob/objects/Duty.dart';
import 'package:wyob/objects/FTL.dart';
import 'package:wyob/utils/DateTimeUtils.dart';
import 'package:wyob/widgets/FtlDateWidget.dart';
import 'package:wyob/widgets/FtlTimeWidget.dart';

class FtlMainPage extends StatefulWidget {

  final FTL ftl;

  FtlMainPage(Duty duty) : ftl = FTL(duty);

  _FtlMainPageState createState() => _FtlMainPageState();
}

class _FtlMainPageState extends State<FtlMainPage> {

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FTL calculator'),
      ),
      body: FtlMainWidget(widget.ftl),
    );
  }
}

class FtlMainWidget extends StatefulWidget {

  final FTL ftl;

  FtlMainWidget(this.ftl);

  _FtlMainWidgetState createState() => _FtlMainWidgetState();
}

/// This class draws the page and interacts with the FTL object to get
/// information.
class _FtlMainWidgetState extends State<FtlMainWidget> {

  static const int DEFAULT_NUMBER_OF_LANDINGS = 1;

  DateTime _reportingDate;
  TimeOfDay _reportingTime;
  int _numberOfLandings = DEFAULT_NUMBER_OF_LANDINGS;
  TimeOfDay _onBlocksTime;
  Duration _timeZoneDifference = Duration.zero;

  FTL getFTL() {
    if (this._reportingDate == null || this._reportingTime == null ||
        this._onBlocksTime == null) return null;
    return FTL.fromWidget(
        reportingDate: this._reportingDate,
        reportingTime: this._reportingTime,
        numberOfLandings: this._numberOfLandings,
        onBlocks: this._onBlocksTime,
        timeZoneDifference: this._timeZoneDifference
    );
  }

  void initState() {
    super.initState();
    if (widget.ftl != null && widget.ftl.reporting != null) {
      _reportingDate = widget.ftl.reporting.loc;
      _reportingTime = TimeOfDay.fromDateTime(_reportingDate);
      _reportingDate = DateTime(_reportingDate.year, _reportingDate.month, _reportingDate.day);

      _numberOfLandings = widget.ftl.numberOfLandings;
      _onBlocksTime = TimeOfDay.fromDateTime(widget.ftl.onBlocks.loc);
      _timeZoneDifference =  widget.ftl.onBlocks.gmtDiff - widget.ftl.reporting.gmtDiff;
    }
  }

  void _setDate(DateTime newDate) {
    setState(() {
      _reportingDate = newDate;
    });
  }

  void _setReporting(TimeOfDay newTime) {
    setState(() {
      _reportingTime = newTime;
    });
  }

  void _setOnBlocks(TimeOfDay newTime) {
    setState(() {
      _onBlocksTime = newTime;
    });
  }
  
  String _getUTCDifferenceString() {
    String result = '';
    _timeZoneDifference > Duration.zero ? result += '+' : result += '-';
    if (_timeZoneDifference.inHours.abs().toString().length < 2) result += '0';
    result += _timeZoneDifference.inHours.abs().toString();
    result += ':';
    if ((_timeZoneDifference - Duration(hours: _timeZoneDifference.inHours)).inMinutes.abs().toString().length < 2) result += '0';
    result += (_timeZoneDifference - Duration(hours: _timeZoneDifference.inHours)).inMinutes.abs().toString();
    return result;
  }

  void _setNumberOfLandings(double value) {
    setState(() {
      _numberOfLandings = value.floor();
    });
  }

  List<ListTile> _getInputDataWidgets(BuildContext context) {

    var inputDataWidgets = <ListTile>[];

    // Date and reporting
    inputDataWidgets.add(
      ListTile(title: Row(children: <Widget>[
        Expanded(
          child: FtlDateWidget('Reporting date', this._reportingDate, this._setDate),
        ),
        Expanded(
          child: FtlTimeWidget('Reporting time', this._reportingTime, this._setReporting),
        ),
      ],),)
    );

    // Number of landings
    inputDataWidgets.add(
        ListTile(title: Row(children: <Widget>[
          Slider(
            value: _numberOfLandings.roundToDouble(),
            min: 1.0,
            max: 8.0,
            onChanged: (value) {
              this._setNumberOfLandings(value);
            },
          ),
          Expanded(
            child: Text(_numberOfLandings.floor().toString() + ' Landings'),
          ),
        ],),)
    );

    // Number of landings
    inputDataWidgets.add(
        ListTile(title: Row(children: <Widget>[
          Expanded(
            flex: 3,
            child: FtlTimeWidget('On Blocks', _onBlocksTime, this._setOnBlocks),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: <Widget>[
                Text(
                  'GMT diff.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
                Text(_getUTCDifferenceString(), textScaleFactor: 1.2,),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                FlatButton(
                  child: Text('+', textScaleFactor: 1.5,),
                  onPressed: () {
                    setState(() {
                      _timeZoneDifference += Duration(minutes: 15);
                    });
                  },
                ),
                FlatButton(
                  child: Text('-', textScaleFactor: 1.5,),
                  onPressed: () {
                    setState(() {
                      _timeZoneDifference -= Duration(minutes: 15);
                    });
                  },
                )
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.info, color: Colors.blue),
            onPressed: () =>
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('GMT Difference?'),
                    content: Text('This is the difference of time zones between '
                        'the country where the last flight ends and the reporting country. \n'
                        'Example: Flight from Muscat (GMT +4) to Frankfurt (GMT +2 during summer) '
                        'should be -02:00'
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Got it...'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                }
              ),
          )
        ],),)
    );
    return inputDataWidgets;
  }

  List<Widget> _getRestWidgets() {
    var widgets = <Widget>[];

    if (getFTL() != null) {
      FTL ftl = getFTL();
      widgets.add(
        Column(
          children: <Widget>[
            Container(
              constraints: BoxConstraints.expand(height: 30.0),
              decoration: BoxDecoration(color: Colors.cyanAccent),
              child: Center(
                child: Text('MINIMUM REST:', textScaleFactor: 1.2,),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(child: Text('Starts: '),),
                Text(ftl.rest.start.localDayString + ' ', textScaleFactor: 1.2,),
                Expanded(
                  child: Text(ftl.rest.start.localTimeString, textScaleFactor: 1.2,),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(child: Text('Ends: '),),
                Text(ftl.rest.end.localDayString + ' ', textScaleFactor: 1.2,),
                Expanded(
                  child: Text(ftl.rest.end.localTimeString, textScaleFactor: 1.2,),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(child: Text('Duration: '),),
                Expanded(
                  child: Text(ftl.rest.durationString, textScaleFactor: 1.2,),
                )
              ],
            ),
          ],
        )
      );
    }
    return widgets;
  }

  List<Widget> _getFDPWidgets() {
    var widgets = <Widget>[];

    if (getFTL() != null && getFTL().flightDutyPeriod != null) {
      FTL ftl = getFTL();
      widgets.add(
        Column(
          children: <Widget>[
            Container(
              constraints: BoxConstraints.expand(height: 30.0),
              decoration: BoxDecoration(color: Colors.deepOrangeAccent),
              child: Center(
                child: Text('FLIGHT DUTY PERIOD', textScaleFactor: 1.2,),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(child: Text('Starts: '),),
                Text(ftl.flightDutyPeriod.start.localDayString + ' ', textScaleFactor: 1.2,),
                Expanded(
                  child: Text(ftl.flightDutyPeriod.start.localTimeString, textScaleFactor: 1.2,),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(child: Text('Ends: '),),
                Text(ftl.flightDutyPeriod.end.localDayString + ' ', textScaleFactor: 1.2,),
                Expanded(
                  child: Text(ftl.flightDutyPeriod.end.localTimeString, textScaleFactor: 1.2,),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(child: Text('Duration: '),),
                Expanded(
                  child: Text(ftl.flightDutyPeriod.durationString, textScaleFactor: 1.2,),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(child: Text('MAX: '),),
                Expanded(
                  child: Text(
                    durationToStringHM(ftl.flightDutyPeriod.maxFlightDutyPeriodLength),
                    textScaleFactor: 1.2,
                  ),
                ),
                Text('ends: '),
                Expanded(
                  child: Text(
                    ftl.flightDutyPeriod.maxFlightDutyPeriodEndTime.localTimeString,
                    textScaleFactor: 1.2,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(child: Text('EXTENDED: '),),
                Expanded(
                  child: Text(
                    durationToStringHM(ftl.flightDutyPeriod.extendedFlightDutyPeriodLength),
                    textScaleFactor: 1.2,
                  ),
                ),
                Text('ends: '),
                Expanded(
                  child: Text(
                    ftl.flightDutyPeriod.extendedFlightDutyPeriodEndTime.localTimeString,
                    textScaleFactor: 1.2,
                  ),
                ),
              ],
            ),
          ],
        )
      );
    }

    return widgets;
  }

  Widget build(BuildContext context) {

    List<Widget> tiles = [];

    tiles.add(Center(child:
        Text('All times local...', style: TextStyle(fontStyle: FontStyle.italic),)));
    tiles.addAll(_getInputDataWidgets(context));
    tiles.addAll(_getRestWidgets());
    tiles.addAll(_getFDPWidgets());

    return ListView(
      children: tiles,
    );
  }
}

