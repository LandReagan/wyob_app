import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'package:wyob/objects/Duty.dart';
import 'package:wyob/objects/FTL.dart';
import 'package:wyob/utils/DateTimeUtils.dart';
import 'package:wyob/widgets/PeriodWidgets.dart';
import 'package:wyob/widgets/FtlDateWidget.dart';
import 'package:wyob/widgets/FtlTimeWidget.dart';
import 'package:wyob/widgets/GMTDiffWidget.dart';
import 'package:wyob/widgets/StandbyToggleWidget.dart';
import 'package:wyob/widgets/StandbyTypeWidget.dart';

class FtlMainPage extends StatefulWidget {

  final Duty _duty;
  final Duty _previous;
  FtlMainPage(this._duty, this._previous);

  _FtlMainPageState createState() => _FtlMainPageState();
}

class _FtlMainPageState extends State<FtlMainPage> {

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FTL calculator'),
      ),
      body: FtlMainWidget(widget._duty, widget._previous),
    );
  }
}

class FtlMainWidget extends StatefulWidget {

  final Duty _duty;
  final Duty _previous;

  FtlMainWidget(this._duty, this._previous);

  _FtlMainWidgetState createState() => _FtlMainWidgetState();
}

/// This class draws the page and interacts with the FTL object to get
/// information.
class _FtlMainWidgetState extends State<FtlMainWidget> {

  static const int DEFAULT_NUMBER_OF_LANDINGS = 1;

  bool _isStandby = false;
  TimeOfDay _standbyStartTime;
  STANDBY_TYPE _standbyType = STANDBY_TYPE.HOME;

  DateTime _reportingDate;
  TimeOfDay _reportingTime;
  Duration _reportingGMTDiff;
  int _numberOfLandings = DEFAULT_NUMBER_OF_LANDINGS;
  TimeOfDay _onBlocksTime;
  Duration _onBlocksGMTDiff;

  bool get isComplete {
    if (_isStandby && _standbyStartTime == null) return false;
    if (this._reportingDate == null || this._reportingTime == null ||
        this._onBlocksTime == null || this._reportingGMTDiff == null ||
        this._onBlocksGMTDiff == null) return false;
    return true;
  }

  FTL getFTL() {
    if (!isComplete) return null;
    return FTL.fromWidget(
        reportingDate: this._reportingDate,
        reportingTime: this._reportingTime,
        reportingGMTDiff: this._reportingGMTDiff,
        numberOfLandings: this._numberOfLandings,
        onBlocks: this._onBlocksTime,
        onBlocksGMTDiff: this._onBlocksGMTDiff,
        standbyStartTime: this._standbyStartTime,
        standbyType: this._standbyType
    );
  }

  void initState() {
    super.initState();
    if (widget._duty != null) {
      _reportingDate = widget._duty.startTime.loc;
      _reportingTime = TimeOfDay.fromDateTime(_reportingDate);
      _reportingDate = DateTime(_reportingDate.year, _reportingDate.month, _reportingDate.day);
      _reportingGMTDiff = widget._duty.startTime.gmtDiff;
      _numberOfLandings = widget._duty.flights.length;
      _onBlocksTime = TimeOfDay.fromDateTime(widget._duty.lastFlight.endTime.loc);
      _onBlocksGMTDiff = widget._duty.lastFlight.endTime.gmtDiff;
    }
    if (widget._previous != null && widget._previous.isStandby) {
      _isStandby = true;
      _reportingDate = widget._previous.startTime.loc;
      _standbyStartTime = TimeOfDay.fromDateTime(_reportingDate);
      _standbyType = widget._previous.nature == DUTY_NATURE.AIRP_SBY ? STANDBY_TYPE.AIRPORT : STANDBY_TYPE.HOME;
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

  void _toggleStandby(bool isStandby) {
    setState(() {
      this._isStandby = isStandby;
    });
  }

  void _setStandbyStartTime(TimeOfDay newTime) {
    setState(() {
      _standbyStartTime = newTime;
    });
  }

  void _toggleStandbyType(STANDBY_TYPE type) {
    setState(() {
      _standbyType = type;
    });
  }

  List<ListTile> _getInputDataWidgets(BuildContext context) {

    var inputDataWidgets = <ListTile>[];

    String dateWidgetTitle = _isStandby ? 'StandBy Start Date' : 'Reporting Date';

    // Date
    inputDataWidgets.add(
      ListTile(title: Row(children: <Widget>[
        Expanded(
          child: FtlDateWidget(dateWidgetTitle, this._reportingDate, this._setDate),
        ),
        Expanded(
          child: StandbyToggleWidget('From StandBy?', _toggleStandby, _isStandby),
        )
    ]),),);

    // Standby data
    if (_isStandby) {
      inputDataWidgets.add(
        ListTile(
          title: Row(
            children: <Widget>[
              Expanded(
                child: FtlTimeWidget(
                    'StandBy start time', _standbyStartTime, _setStandbyStartTime),
              ),
              Expanded(
                child: StandbyTypeWidget(_toggleStandbyType),
              )
            ],
          ),
        )
      );
    }

    // Reporting data
    inputDataWidgets.add(
      ListTile(title: Row(children: <Widget>[
        Expanded(
          flex: 5,
          child: FtlTimeWidget('Flight Reporting time', this._reportingTime, this._setReporting),
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

  List<Widget> _getDPWidgets() {

    var widgets = <Widget>[];
    FTL ftl = getFTL();
    if (ftl != null && ftl.dutyPeriod != null) {
      widgets.add(DutyPeriodWidget(ftl));
    }
    return widgets;
  }

  List<Widget> _getRestWidget() {

    var widgets = <Widget>[];
    if (getFTL() != null) {
      FTL ftl = getFTL();
      widgets.add(RestPeriodWidget(ftl));
    }
    return widgets;
  }

  List<Widget> _getFDPWidgets() {

    var widgets = <Widget>[];
    if (getFTL() != null && getFTL().flightDutyPeriod != null) {
      FTL ftl = getFTL();
      widgets.add(FlightDutyPeriodWidget(ftl));
    }
    return widgets;
  }

  Widget build(BuildContext context) {

    List<Widget> tiles = [];

    tiles.add(Center(child:
        Text('All times local...', style: TextStyle(fontStyle: FontStyle.italic),)));
    tiles.addAll(_getInputDataWidgets(context));
    tiles.addAll(_getFDPWidgets());
    tiles.add(Divider(color: Colors.white, height: 3.0,));
    tiles.addAll(_getDPWidgets());
    tiles.add(Divider(color: Colors.white, height: 3.0,));
    tiles.addAll(_getRestWidget());

    return ListView(
      children: tiles,
    );
  }
}

