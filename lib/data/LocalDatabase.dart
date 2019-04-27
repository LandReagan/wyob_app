import 'dart:io' show File;
import 'dart:convert' show json;

import 'package:path_provider/path_provider.dart';
import 'package:wyob/WyobException.dart';
import 'package:wyob/iob/IobConnector.dart';
import 'package:wyob/utils/Parsers.dart';
import 'package:wyob/iob/GanttDutyFactory.dart';

import 'package:wyob/utils/DateTimeUtils.dart' show AwareDT;
import 'package:wyob/objects/Duty.dart';
import 'package:wyob/utils/DateTimeUtils.dart';


class LocalDatabase {

  Map<String, dynamic> _root;
  bool _ready;
  AwareDT _updateTime;
  final String _fileName;

  static const String DEFAULT_FILE_NAME = 'database.json';

  LocalDatabase({filepath: DEFAULT_FILE_NAME}) :
        _root = null, _ready = false, _fileName = filepath;

  Map<String, dynamic> get rootData => _root;
  bool get ready => _ready;

  Future<void> connect() async {
    _root = await _getLocalData();
    _updateTime = _root['last_update'] != '' ? AwareDT.fromString(_root['last_update']) : null;
    _checkIntegrity();
    _ready = true;
  }

  /// LocalDatabase inner method to update duties from the IOB system. Takes 2
  /// DateTimes [fromParameter] and [toParameter] as time interval.
  ///
  /// The system limitation impose a 30 days maximum interval, this method will
  /// use a 20 days interval repeated until the full interval has been covered.
  ///
  /// Throws:
  /// - [WyobExceptionCredentials] if credentials are missing,
  /// - [WYOBException] if another error occured.
  Future<void> updateFromGantt({DateTime fromParameter, DateTime toParameter}) async {

    DateTime from = fromParameter != null ? fromParameter : DateTime.now().subtract(Duration(days: 5));
    DateTime to = fromParameter != null ? fromParameter : DateTime.now().add(Duration(days: 30));

    IobConnector connector;
    try {
      connector = IobConnector(
          _getCredentials()['username'], _getCredentials()['password']);
    } catch (e) {
      // Has to be dealt with at higher level...
      throw e;
    }

    const int INTERVAL_DAYS = 20;
    while (from.isBefore(to)) {
      // get Gantt duties from 'from' to 'to'
      // Get the references...
      String referencesString = await connector.getFromToGanttDuties(
          from,
          from.add(Duration(days: INTERVAL_DAYS))
      );

      List<Map<String, dynamic>> references = parseGanttMainTable(referencesString);

      List<Duty> duties = [];
      for (var reference in references) {
        String rotationStringLocal =
        reference['type'] == 'Trip' ?
        await connector.getGanttDutyTripLocal(
            reference['personId'], reference['persAllocId']) :
        await connector.getGanttDutyAcyLocal(
            reference['personId'], reference['persAllocId']);

        String rotationStringUtc =
        reference['type'] == 'Trip' ?
        await connector.getGanttDutyTripUtc(
            reference['personId'], reference['persAllocId']) :
        await connector.getGanttDutyAcyUtc(
            reference['personId'], reference['persAllocId']);

        List<Map<String, dynamic>> rotationDutiesDataLocal = parseGanttDuty(
            rotationStringLocal);
        List<Map<String, dynamic>> rotationDutiesDataUtc = parseGanttDuty(
            rotationStringUtc);

        List<Duty> rotationDuties = GanttDutyFactory.run(
            rotationDutiesDataLocal, rotationDutiesDataUtc);
        duties.addAll(rotationDuties);
      }

      // set duties
      this.setDuties(duties);

      from = from.add(Duration(days: INTERVAL_DAYS));
    }
  }

  void setDuties(List<Duty> newDuties) {
    // todo!
    newDuties.forEach((duty) => print(duty));
  }

  List<Duty> getDuties(DateTime from, DateTime to) {
    if (_root['duties'].length > 0) {
      List<Map<String, dynamic>> allRawDuties = _root['duties'];
      List<Duty> allDuties = allRawDuties.map((rawDuty) {
        return Duty.fromMap(rawDuty);
      }).toList();
      allDuties.removeWhere((duty) {
        return duty.startTime.loc.isAfter(to) || duty.endTime.loc.isBefore(from);
      });
      return allDuties;
    }
    return [];
  }

  Future<Map<String, dynamic>> _getLocalData() async {
    String rootPath = await _getRootPath();
    String databasePath = rootPath + '/' + _fileName;
    String rawData = await _readDatabaseFile(databasePath);
    return json.decode(rawData);
  }

  Future<String> _readDatabaseFile(String filePath) async {
    return await File(filePath).readAsString();
  }

  static Future<String> _getRootPath() async {

    String rootPath = "";
    try {
      rootPath = (await getApplicationDocumentsDirectory()).path;
    } on Exception { // probable cause is we are testing...
      rootPath = "test";
    }
    return rootPath;
  }

  /// Gets credentials from the database. Throws [WYOBException] if database is
  /// not ready, or [WyobExceptionCredentials] if 'username' or 'password' are
  /// set to empty string.
  Map<String, dynamic> _getCredentials() {

    if (!ready) {
      throw WyobException('In LocalDatabase object, _getCredentials was called'
          'with database not ready!');
    }

    Map<String, dynamic> userData = _root['user_data'];

    if (userData['username'] == '' || userData['password'] == '') {
      throw WyobExceptionCredentials('Credentials empty in the database!');
    }

    return {
      'username': userData['username'],
      'password': userData['password']
    };
  }

  /// Checks database integrity in terms of available fields, lists, sets...
  /// Throws [WyobExceptionDatabaseIntegrity] in case of any error found.
  void _checkIntegrity() {
    if (_root == null) {
      throw WyobExceptionDatabaseIntegrity('Database Root is empty!');
    }

    if (_root['user_data'] == null) {
      throw WyobExceptionDatabaseIntegrity('Database User Data ("user_data") not found!');
    }

    if (_root['user_data']['username'] == null || _root['user_data']['password'] == null) {
      throw WyobExceptionDatabaseIntegrity(
          'Database User Data ("user_data") incorrect, with username or password set to null!');
    }
  }
}
