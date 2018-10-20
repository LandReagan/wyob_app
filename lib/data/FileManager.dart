import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;


class FileManager {

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
  static void writeUserData(String encodedUserData) async {

    print("Writing user data!");

    (await _getUserDataFile()).writeAsStringSync(encodedUserData);
  }

  static Future<String> readUserData() async {

    if ((await _getCurrentDutiesFile()).existsSync()) {
      return (await _getCurrentDutiesFile()).readAsStringSync();
    } else {
      /// TODO: This is for testing purpose only! Replace by 'return "";' for
      /// deployment...
      //return await rootBundle.loadString('duties.json');
      return "";
    }
  }

  static Future<String> _getRootPath() async {
    return getApplicationDocumentsDirectory()
        .then((directory) => directory.path);
  }

  static Future<File> _getCurrentDutiesFile() async {
    return new File((await _getRootPath()) + "/duties.json");
  }

  static Future<File> _getUserDataFile() async {
    return File((await _getRootPath()) + "/user.json");
  }
}
