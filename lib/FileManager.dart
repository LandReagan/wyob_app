import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;


class FileManager {

  static void writeCurrentDuties(String encodedDuties) async {
    (await _getCurrentDutiesFile()).writeAsStringSync(encodedDuties);
  }

  static Future<String> readCurrentDuties() async {
    return await rootBundle.loadString('duties.json');
    /*
    if ((await _getCurrentDutiesFile()).existsSync()) {
      return (await _getCurrentDutiesFile()).readAsStringSync();
    } else {
      return "";
    }
    */
  }

  static Future<String> _getRootPath() async {
    return getApplicationDocumentsDirectory()
        .then((directory) => directory.path);
  }

  static Future<File> _getCurrentDutiesFile() async {
    print((await _getRootPath()) + "/duties.json");
    return new File((await _getRootPath()) + "/duties.json");
  }

  static Future<Map<String, dynamic>> getUserSettings() async {
    String jsonString = await rootBundle.loadString('user_data.json');
    return json.decode(jsonString);
  }
}
