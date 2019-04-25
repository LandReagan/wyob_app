import 'dart:io' show File;
import 'dart:convert' show json;

import 'package:path_provider/path_provider.dart';

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
    _updateTime = AwareDT.fromString(_root['last_update']);
    _ready = true;
  }

  List<Duty> getDuties(DateTime from, DateTime to) {
    List<Map<String, dynamic>> allRawDuties = _root['duties'];
    List<Duty> allDuties = allRawDuties.map((rawDuty) {
      return Duty.fromMap(rawDuty);
    }).toList();
    allDuties.removeWhere((duty) {
      return duty.startTime.loc.isAfter(to) || duty.endTime.loc.isBefore(from);
    });
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

  void _setUpdateTimeNow() {
    _updateTime = AwareDT.fromDateTimes(DateTime.now(), DateTime.now().toUtc());
  }
}
