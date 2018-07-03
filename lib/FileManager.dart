import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';


class FileManager {

  static void writeCurrentDuties(String encodedDuties) async {
    (await _getCurrentDutiesFile()).writeAsStringSync(encodedDuties);
  }

  static Future<String> readCurrentDuties() async {
    if ((await _getCurrentDutiesFile()).existsSync()) {
      return (await _getCurrentDutiesFile()).readAsStringSync();
    } else {
      return "";
    }
  }

  static Future<String> _getRootPath() async {
    return getApplicationDocumentsDirectory()
        .then((directory) => directory.path);
  }

  static Future<File> _getCurrentDutiesFile() async {
    return new File((await _getRootPath()) + "currentDuties.json");
  }
}
