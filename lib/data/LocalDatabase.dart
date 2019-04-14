import 'dart:io' show File;
import 'dart:convert' show json;

import 'package:path_provider/path_provider.dart';


class LocalDatabase {

  Map<String, dynamic> _root;
  bool _ready;
  final String _fileName;

  static const String DEFAULT_FILE_NAME = 'database.json';

  LocalDatabase({filepath: DEFAULT_FILE_NAME}) :
        _root = null, _ready = false, _fileName = filepath;

  Future<void> connect() async {
    _root = await _getLocalData();
    _ready = true;
  }

  Map<String, dynamic> get rootData => _root;
  bool get ready => _ready;

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
}
