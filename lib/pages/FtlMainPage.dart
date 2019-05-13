
import 'package:flutter/material.dart';

import 'package:wyob/objects/Duty.dart';
import 'package:wyob/objects/FTL.dart';
import 'package:wyob/utils/DateTimeUtils.dart';
import 'package:wyob/widgets/FtlDateWidget.dart';
import 'package:wyob/widgets/FtlTimeWidget.dart';
import 'package:wyob/widgets/GMTDiffWidget.dart';

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
  Duration _reportingGMTDiff;
  int _numberOfLandings = DEFAULT_NUMBER_OF_LANDINGS;
  TimeOfDay _onBlocksTime;
  Duration _onBlocksGMTDiff;

  FTL getFTL() {
    if (this._reportingDate == null || this._reportingTime == null ||
        this._onBlocksTime == null || this._reportingGMTDiff == null ||
        this._onBlocksGMTDiff == null) return null;
    return FTL.fromWidget(
        reportingDate: this._reportingDate,
        reportingTime: this._reportingTime,
        reportingGMTDiff: this._reportingGMTDiff,
        numberOfLandings: this._numberOfLandings,
        onBlocks: this._onBlocksTime,
        onBlocksGMTDiff: this._onBlocksGMTDiff
    );
  }

  void initState() {
    super.initState();
    if (widget.ftl != null && widget.ftl.reporting != null) {
      _reportingDate = widget.ftl.reporting.loc;
      _reportingTime = TimeOfDay.fromDateTime(_reportingDate);
      _reportingDate = DateTime(_reportingDate.year, _reportingDate.month, _reportingDate.day);
      _reportingGMTDiff = widget.ftl.reporting.gmtDiff;
      _numberOfLandings = widget.ftl.numberOfLandings;
      _onBlocksTime = TimeOfDay.fromDateTime(widget.ftl.onBlocks.loc);
      _onBlocksGMTDiff = widget.ftl.onBlocks.gmtDiff;
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

  void _setReportingGMTDiff(Duration duration) {
    setState(() {
      _reportingGMTDiff = duration;
    });
  }

  void _setNumberOfLandings(double value) {
    setState(() {
      _numberOfLandings = value.floor();
    });
  }

  void _setOnBlocks(TimeOfDay newTime) {
    setState(() {
      _onBlocksTime = newTime;
    });
  }

  void _setOnBlocksGMTDiff(Duration duration) {
    setState(() {
      _onBlocksGMTDiff = duration;
    });
  }

  List<ListTile> _getInputDataWidgets(BuildContext context) {

    var inputDataWidgets = <ListTile>[];

    // Date
    inputDataWidgets.add(
      ListTile(title: Row(children: <Widget>[
        Expanded(
          child: FtlDateWidget('Reporting date', this._reportingDate, this._setDate),
        ),
    ]),),);

    // Reporting data
    inputDataWidgets.add(
      ListTile(title: Row(children: <Widget>[
        Expanded(
          flex: 5,
          child: FtlTimeWidget('Reporting time', this._reportingTime, this._setReporting),
        ),
        GMTDiffWidget('GMT Diff.', _reportingGMTDiff, _setReportingGMTDiff),
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

    // On blocks data
    inputDataWidgets.add(
        ListTile(title: Row(children: <Widget>[
          Expanded(
            flex: 5,
            child: FtlTimeWidget('On Blocks', _onBlocksTime, this._setOnBlocks),
          ),
          GMTDiffWidget('GMT Diff.', _onBlocksGMTDiff, _setOnBlocksGMTDiff),
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

