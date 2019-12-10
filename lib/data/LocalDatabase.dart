import 'dart:convert' show json;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:async/async.dart';

import 'package:wyob/WyobException.dart';
import 'package:wyob/iob/IobConnector.dart';
import 'package:wyob/iob/IobConnectorData.dart';
import 'package:wyob/objects/Crew.dart';
import 'package:wyob/objects/MonthlyAggregation.dart';
import 'package:wyob/objects/Statistics.dart';
import 'package:wyob/utils/Parsers.dart';
import 'package:wyob/iob/GanttDutyFactory.dart';

import 'package:wyob/utils/DateTimeUtils.dart' show AwareDT;
import 'package:wyob/objects/Duty.dart';
import 'package:wyob/objects/Rank.dart';
import 'package:wyob/utils/DateTimeUtils.dart';

/// Singleton class for our database.
class LocalDatabase {

  Map<String, dynamic> _root;
  bool _ready = true;
  String _fileName = DEFAULT_FILE_NAME;

  List<Statistics> _statistics;

  DateTime earliestDutyDate;
  DateTime latestDutyDate;

  IobConnector _connector;

  CancelableOperation updateOperation;

  ChangeNotifier notifier;

  static const String DEFAULT_FILE_NAME = 'database.json';

  static const Map<String, dynamic> EMPTY_DATABASE_STRUCTURE = {
    "user_data": {"username": null, "password": null},
    "app_settings": {},
    "last_update": null,
    "duties": [],
    "crew": []
  };

  static final LocalDatabase _instance = LocalDatabase._private();

  factory LocalDatabase() {
    return _instance;
  }

  LocalDatabase._private() {
    _connector = IobConnector();
    notifier = ChangeNotifier();
  }

  Map<String, dynamic> get rootData => _root;

  bool get ready => _ready;

  DateTime get updateTimeLoc => _getUpdateTime()?.loc;

  DateTime get updateTimeUtc => _getUpdateTime()?.utc;

  IobConnector get connector {
    return _connector;
  }

  List<Statistics> get statistics {
    if (_statistics != null) return _statistics;
    _statistics = buildStatistics();
    return _statistics;
  }

  Future<void> connect() async {
    _root = await _readLocalData();
    try {
      _checkIntegrity();
      _connector.setCredentials(
          _getCredentials()['username'], _getCredentials()['password']);
    } on WyobExceptionCredentials catch (e) {
      Logger().w('No credentials...');
      _ready = true;
      throw e;
    } on WyobExceptionDatabaseIntegrity {
      // todo: Handle file system problems... How???
      Logger().w("Unhandled exception related to database integrity");
    }
    _ready = true;
  }

  Future<void> setCredentials(
      String username, String password, String rank) async {
    Logger().i("Setting credentials...");
    _ready = false;
    try {
      _root = await _readLocalData();
      _root['user_data']['username'] = username;
      _root['user_data']['password'] = password;
      _root['user_data']['rank'] = rank;
      await _writeLocalData();
      _ready = true;
    } on Exception catch (e) {
      _ready = true;
      throw WyobException(
          'File system problem, most likely... Error thrown: ' + e.toString());
    }
    _ready = true;
  }

  /// IOB duties update, asynchronous and cancellable.
  Future<void> updateFromGantt(
      {DateTime fromParameter, DateTime toParameter, VoidCallback callback}
  ) async {
    updateOperation = CancelableOperation.fromFuture(
      _updateFromGantt(
        fromParameter: fromParameter,
        toParameter: toParameter,
        callback: callback
      )
    );
  }

  /// LocalDatabase inner method to update duties from the IOB system. Takes 2
  /// DateTimes [fromParameter] and [toParameter] as time interval. It updates
  /// the [_updateTime] field as well
  ///
  /// The system limitation impose a 30 days maximum interval, this method will
  /// use a 25 days interval repeated until the full interval has been covered.
  ///
  /// Throws:
  /// - [WyobExceptionCredentials] if credentials are missing,
  /// - [WYOBException] if another error occured.
  Future<void> _updateFromGantt(
      {DateTime fromParameter, DateTime toParameter, VoidCallback callback}) async {
    DateTime from = (fromParameter != null
        ? fromParameter
        : updateTimeLoc?.subtract(Duration(days: 1)));
    DateTime to = (toParameter != null
        ? toParameter
        : DateTime.now().add(Duration(days: 30)));

    if (from == null) from = DateTime.now().subtract(Duration(days: 3));

    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day, 23, 59);

    Logger().i(
        "Fetching period from: " +
        dateTimeToString(from) +
        " to: "
        + dateTimeToString(to)
    );

    const int INTERVAL_DAYS = 25;
    while (from.isBefore(to)) {

      Logger().i(
        'Fetching interval from: ' +
        dateTimeToString(from) +
        ' to: ' +
        dateTimeToString(from.add(Duration(days: INTERVAL_DAYS)))
      );
      // get Gantt duties from 'from' to 'to'
      // Get the references...

      String referencesString = await connector.getFromToGanttDuties(
          from, from.add(Duration(days: INTERVAL_DAYS)));

      if (referencesString == "" || referencesString == null) return;

      List<Map<String, dynamic>> references =
          parseGanttMainTable(referencesString);

      List<Duty> duties = [];
      for (int i = 0; i < references.length; i++) {
        var reference = references[i];
        String rotationStringLocal = reference['type'] == 'Trip'
            ? await connector.getGanttDutyTripLocal(i + 1, references.length,
                reference['personId'], reference['persAllocId'])
            : await connector.getGanttDutyAcyLocal(i + 1, references.length,
                reference['personId'], reference['persAllocId']);

        String rotationStringUtc = reference['type'] == 'Trip'
            ? await connector.getGanttDutyTripUtc(
                reference['personId'], reference['persAllocId'])
            : await connector.getGanttDutyAcyUtc(
                reference['personId'], reference['persAllocId']);

        List<Map<String, dynamic>> rotationDutiesDataLocal =
            parseGanttDuty(rotationStringLocal);
        List<Map<String, dynamic>> rotationDutiesDataUtc =
            parseGanttDuty(rotationStringUtc);

        List<Duty> rotationDuties = GanttDutyFactory.run(
            rotationDutiesDataLocal, rotationDutiesDataUtc);
        duties.addAll(rotationDuties);
      }
      // Add the "fake" LAYOVER duties
      for (int i = 0; i < duties.length - 1; i++) {
        Duty current = duties[i];
        Duty next = duties[i + 1];
        if (current.isFlight &&
            next.isFlight &&
            current.endPlace.IATA != 'MCT' &&
            next.startPlace.IATA != 'MCT' &&
            next.startTime.difference(current.endTime) >= Duration(hours: 10)) {
          duties.insert(
              i + 1,
              Duty.layover(
                  startTime: current.endTime,
                  endTime: next.startTime,
                  airport: current.endPlace));
        }
      }

      if (duties.isNotEmpty) await setDuties(duties);

      from = from.add(Duration(days: INTERVAL_DAYS));
    }
    if (callback != null) callback();
    //todo: Get it better, it's shit
    connector.changeStatus(CONNECTOR_STATUS.OFF);
    await _setUpdateTime(AwareDT.now());
  }

  /// It set a batch of new or updated duties in the database by overwriting
  /// existing duties using times: any overlapping duty will be erased by the
  /// new one. The list of duties is then sorted on ascending start time...
  Future<void> setDuties(List<Duty> newDuties) async {
    List<Duty> allDuties = getDutiesAll();

    newDuties.sort(
        (duty1, duty2) => duty1.startTime.utc.compareTo(duty2.startTime.utc));

    /* Previous logic
    DateTime start = DateTime(newDuties.first.startTime.loc.year,
        newDuties.first.startTime.loc.month, newDuties.first.startTime.loc.day);
    DateTime end = DateTime(newDuties.last.endTime.loc.year,
        newDuties.last.endTime.loc.month, newDuties.last.endTime.loc.day);
     */

    Logger().d("Removing old duties...");
    allDuties.removeWhere((duty) {
      return duty.endTime.utc.isAfter(newDuties.first.startTime.utc) &&
          duty.startTime.utc.isBefore(newDuties.last.endTime.utc);
    });

    Logger().d("Adding new duties...");
    allDuties.addAll(newDuties);

    allDuties.sort(
        (duty1, duty2) => duty1.startTime.utc.compareTo(duty2.startTime.utc));

    List<Map<String, dynamic>> newRawDuties =
        allDuties.map((duty) => duty.toMap()).toList();

    _root['duties'] = newRawDuties;
    await _writeLocalData();
    _statistics = buildStatistics();
    notifier.notifyListeners();
  }

  /// Returns all duties from the file system if any, empty list else.
  List<Duty> getDutiesAll() {

    if (_root['duties'].length > 0) {

      List<Map<String, dynamic>> allRawDuties =
          List<Map<String, dynamic>>.from(_root['duties']);

      List<Duty> allDuties = allRawDuties.map((rawDuty) {
        return Duty.fromMap(rawDuty);
      }).toList();

      earliestDutyDate = allDuties.first.startTime.loc;
      latestDutyDate = allDuties.last.startTime.loc;

      return allDuties;
    }

    return [];
  }

  List<Duty> getDuties(DateTime from, DateTime to) {
    List<Duty> allDuties = getDutiesAll();
    allDuties.removeWhere((duty) {
      return duty.startTime.loc.isAfter(to) || duty.endTime.loc.isBefore(from);
    });
    allDuties.forEach((duty) {
      if (connector.acknowledgeDutyIds.contains(duty.id))
        duty.acknowledge = true;
    });
    return allDuties;
  }

  /// Returns aggregation of duties and statistics in a list of Maps.
  List<Map<String, dynamic>> getDutiesAndStatistics(
      DateTime from, DateTime to) {
    var result = <Map<String, dynamic>>[];
    List<Duty> duties = getDuties(from, to);
    List<Statistics> statistics = _statistics;
    duties.forEach((duty) {
      DateTime correspondingDay = duty.endTime.utc.add(Duration(hours: 4));
      correspondingDay = DateTime(
          correspondingDay.year, correspondingDay.month, correspondingDay.day);
      result.add({
        'duty': duty,
        'stat': statistics.firstWhere((stat) => stat.day == correspondingDay),
      });
    });
    return result;
  }

  List<MonthlyAggregation> getAllMonthlyAggregations() {

    var aggregations = <MonthlyAggregation>[];

    if (earliestDutyDate == null || latestDutyDate == null) getDutiesAll();

    DateTime rolling = DateTime(earliestDutyDate.year, earliestDutyDate.month);
    if (rolling == null) return aggregations;
    DateTime latestMonth = DateTime(latestDutyDate.year, latestDutyDate.month);

    while (rolling.compareTo(latestMonth) <= 0) {
      aggregations.add(MonthlyAggregation(rolling, this));
      if (rolling.month == 12) {
        rolling = DateTime(rolling.year + 1, 1);
      } else {
        rolling = DateTime(rolling.year, rolling.month + 1);
      }
    }

    return aggregations;
  }

  List<Statistics> buildStatistics() {
    var statistics = <Statistics>[];
    List<Duty> duties = getDutiesAll();

    if (duties.length == 0) return statistics;

    // Build all Statistics objects
    DateTime firstDay = duties.first.statistics.first['day'];
    DateTime lastDay = duties.last.statistics.last['day'];
    for (var day = firstDay;
        day != lastDay.add(Duration(days: 1));
        day = day.add(Duration(days: 1))) {
      statistics.add(Statistics(day));
    }

    // Add accumulated values to each impacted day
    int length = statistics.length;
    for (var duty in duties) {
      for (var data in duty.statistics) {

        int startIndex = statistics.indexWhere((stat) {
          return stat.day == data['day'];
        });

        // 7 days duty
        for (int index = startIndex;
            index < length && index < startIndex + 7;
            index++) {
          statistics[index].sevenDaysDutyAccumulation += data['duty'];
        }

        // 28 days duty
        for (int index = startIndex;
            index < length && index < startIndex + 28;
            index++) {
          statistics[index].twentyEightDaysDutyAccumulation += data['duty'];
        }

        // 365 days duty
        for (int index = startIndex;
            index < length && index < startIndex + 365;
            index++) {
          statistics[index].oneYearDutyDaysAccumulation += data['duty'];
        }

        // 28 days block
        for (int index = startIndex;
            index < length && index < startIndex + 28;
            index++) {
          statistics[index].twentyEightDaysBlockAccumulation += data['block'];
        }

        // 365 days block
        for (int index = startIndex;
            index < length && index < startIndex + 365;
            index++) {
          statistics[index].oneYearBlockAccumulation += data['block'];
        }
      }
    }

    for (var stat in statistics) {
      if (stat.day.difference(firstDay) >= Duration(days: 6))
        stat.sevenDaysDutyCompleteness = true;
      if (stat.day.difference(firstDay) >= Duration(days: 28)) {
        stat.twentyEightDaysBlockCompleteness = true;
        stat.twentyEightDaysDutyCompleteness = true;
      }
      if (stat.day.difference(firstDay) >= Duration(days: 365)) {
        stat.oneYearBlockCompleteness = true;
        stat.oneYearDutyDaysCompleteness = true;
      }
    }

    return statistics;
  }

  RANK getRank() {
    Map<String, dynamic> userData = _root['user_data'];
    String rankString = userData['rank'];
    switch (rankString) {
      case 'CPT':
        return RANK.CPT;
      case 'FO':
        return RANK.FO;
      case 'CD':
        return RANK.CD;
      case 'CC / PGC':
        return RANK.CC;
      default:
        return null;
    }
  }
  
  Future<Crew> getCrewInformation(
      DateTime day,
      String flightNumber,
      {bool iobConnection = true}) async
  {

    List<Map<String, dynamic>> crewRootData;

    try {
      crewRootData = List<Map<String, dynamic>>.from(_root['crew']);
    } catch (error) {
      Logger().i("No crew information found in the database.");
      _root['crew'] = [];
      crewRootData = List<Map<String, dynamic>>.from(_root['crew']);
      if (!iobConnection) return null;
    }
    
    if (crewRootData.length > 0) {
      for (var crewEntryData in crewRootData) {
        String dayString;
        String flightNumberString;
        try {
          dayString = crewEntryData['day'];
          flightNumberString = crewEntryData['flight_number'];
        } catch (error) {
          Logger().w("Error while getting crew information in database: " +
              error.toString());
          return null;
        }
        if (dayString == DateFormat("ddMMMyyyy").format(day) &&
            flightNumber == flightNumberString) {
          var crewData = List<Map<String, dynamic>>.from(crewEntryData['crew']);
          return Crew.fromMap(crewData);
        }
      }
      if (!iobConnection) return null; // Crew not found
    } else {
      Logger().w("Crew information list found empty in the database.");
      if (!iobConnection) return null;
    }

    // We reached here if crew has not been found AND iobConnect is true!
    String crewString;
    Crew resultCrew;
    try {
      crewString = await connector.getCrew(day, flightNumber);
      resultCrew = Crew.fromParser(parseCrewPage(crewString));
    } on WyobExceptionParser {
      Logger().w("Crew parser error");
      return null;
    } on WyobExceptionOffline {
      Logger().i("Offline attempt to gather Crew information");
      return null;
    }

    return resultCrew;
  }
  
  Future<void> setCrewInformation(DateTime day, String flightNumber, Crew crew) async {

    var dayString = DateFormat("ddMMMyyyy").format(day);
    var data = {
      'day': dayString, 
      'flight_number': flightNumber, 
      'crew': crew.crewAsMap
    };

    List<Map<String, dynamic>> crewRootData;
    try {
      crewRootData = List<Map<String, dynamic>>.from(_root['crew']);
    } catch (error) {
      Logger().i("No crew information found in the database. Creating section...");
      _root['crew'] = [];
    }

    if (getCrewInformation(day, flightNumber) == null) {
      _root['crew'].add(data);
    }

    await _writeLocalData();
  }

  Future<void> reset() async {
    _root = Map<String, dynamic>.from(EMPTY_DATABASE_STRUCTURE);
    await _writeLocalData();
  }

  bool getAutoFetchOnStartUp() {

    Map<String, dynamic> appSettings = _getAppSettings();

    if (appSettings == null) return true;

    if (appSettings.containsKey("auto_fetch_on_start_up")) {
      return appSettings["auto_fetch_on_start_up"];
    } else {
      return true;
    }
  }

  Future<void> setAutoFetchOnStartUp(bool value) async {
    _root["app_settings"]["auto_fetch_on_start_up"] = value;
    await _writeLocalData();
  }

  Future<void> _setUpdateTime(AwareDT time) async {
    _root['last_update'] = time.toString();
    await _writeLocalData();
  }

  AwareDT _getUpdateTime() {
    if (_root['last_update'] == null || _root['last_update'] == '') return null;
    return AwareDT.fromString(_root['last_update']);
  }

  Future<Map<String, dynamic>> _readLocalData() async {
    if (_ready == false) {
      throw WyobException('File not ready for reading');
    }

    _ready = false;
    String jsonData;
    try {
      Directory rootDirectory = await _getRootDirectory();
      String databasePath = rootDirectory.path + '/' + _fileName;
      Logger().d('Accessing database file at: ' + databasePath);
      File databaseFile = File(databasePath);
      jsonData = await _readDatabaseFile(databasePath);
      _ready = true;
    } on Exception catch (e){
      _ready = true;
      Logger().e('Error accessing filesystem: ' + e.toString());
    }

    return json.decode(jsonData);
  }

  Future<void> _writeLocalData() async {
    if (_ready = true) {
      _ready = false;
      String rootPath = await _getRootPath();
      String databasePath = rootPath + '/' + _fileName;
      String encodedData = json.encode(_root);
      File(databasePath).writeAsStringSync(encodedData, mode: FileMode.write);
      _ready = true;
    }
  }

  Future<String> _readDatabaseFile(String filePath) async {
    String data;
    try {
      data = await File(filePath).readAsString();
    } on FileSystemException {
      // File is not existing, create it...
      data = json.encode(EMPTY_DATABASE_STRUCTURE);
      File(filePath).writeAsStringSync(data);
    }
    return data;
  }

  static Future<String> _getRootPath() async {
    String rootPath;
    try {
      rootPath = (await getApplicationDocumentsDirectory()).path;
      Logger().i("Path: " + rootPath);
    } on Exception {
      Logger().e("Unrecoverable filesystem exception!");
    }
    return rootPath;
  }

  /// Depending on path_provider plugin
  static Future<Directory> _getRootDirectory() async {
    Directory documents = await getApplicationDocumentsDirectory();
    Logger().d('Accessing documents directory at: ' + documents.path);
    return documents;
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

    // todo: Hide this!!!
    Logger().d("Username: " + userData['username'] + " PASSWORD: " + userData['password']);

    return {'username': userData['username'], 'password': userData['password']};
  }

  /// Getter for app settings as Map. Returns null on any error.
  Map<String, dynamic> _getAppSettings() {
    try {
      Map<String, dynamic> appSettings = _root['app_settings'];
      return appSettings;
    } catch (e) {
      Logger().e("LocalDatabase _getAppSettings failed. Error: " + e.toString());
      return null;
    }
  }

  /// Checks database integrity in terms of available fields, lists, sets...
  /// Throws [WyobExceptionDatabaseIntegrity] in case of any error found.
  void _checkIntegrity() {
    if (_root == null) {
      throw WyobExceptionDatabaseIntegrity('Database Root is empty!');
    }

    if (_root['user_data'] == null) {
      throw WyobExceptionDatabaseIntegrity(
          'Database User Data ("user_data") not found!');
    }

    if (_root['user_data']['username'] == null ||
        _root['user_data']['password'] == null) {
      throw WyobExceptionCredentials(
          'Database User Data ("user_data") incorrect, with username or password set to null!');
    }
  }

  @override
  String toString() {
    return _root.toString();
  }
}
