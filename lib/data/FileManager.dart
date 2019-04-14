import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

class FileManager {

  static Future<Map<String, dynamic>> getLocalData() async {
    return await json.decode(await _getLocalDatabase());
  }

  static Future<String> _getLocalDatabase() async {
    return (await _getLocalDatabaseFile()).readAsString();
  }

  // Duties file management
  static void writeCurrentDuties(String encodedDuties) async {

    print("Writing current duties!");

    (await _getCurrentDutiesFile()).writeAsStringSync(encodedDuties);
  }

  static Future<String> readDutiesFile() async {

    if ((await _getCurrentDutiesFile()).existsSync()) {
      return (await _getCurrentDutiesFile()).readAsStringSync();
    } else {
      /// TODO: This is for testing purpose only! Replace by 'return "";' for
      /// deployment...
      //return await rootBundle.loadString('duties.json');
      return "";
    }
  }

  // User data file management
  static Future<void> writeUserData(Map<String, dynamic> userData) async {

    print("Writing user data!");

    (await _getUserDataFile()).writeAsStringSync(json.encode(userData));
  }

  static Future<String> readUserData() async {

    if ((await _getUserDataFile()).existsSync()) {
      return (await _getUserDataFile()).readAsStringSync();
    } else {
      // create a new and empty user data file:
      (await _getUserDataFile()).writeAsStringSync(
        json.encode({
          "username": "",
          "password": ""
        })
      );
      return (await _getUserDataFile()).readAsStringSync();
    }
  }

  static Future<String> _getRootPath() async {
    return getApplicationDocumentsDirectory()
        .then((directory) => directory.path);
  }

  static Future<File> _getLocalDatabaseFile() async {
    return new File((await _getRootPath()) + "/database.json");
  }

  static Future<File> _getCurrentDutiesFile() async {
    return new File((await _getRootPath()) + "/duties.json");
  }

  static Future<File> _getUserDataFile() async {
    return File((await _getRootPath()) + "/user.json");
  }
}
