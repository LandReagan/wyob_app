import 'dart:convert' show json;

import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:wyob/objects/Airport.dart' show Airport;
import 'package:wyob/objects/FTL.dart';
import 'package:wyob/objects/Flight.dart' show Flight;
import 'package:wyob/utils/DateTimeUtils.dart' show AwareDT, durationToString;
import 'package:wyob/widgets/DurationWidget.dart';

enum DUTY_NATURE {
  LEAVE,
  OFF,
  GROUND,
  SIM,
  FLIGHT,
  HOME_SBY,
  AIRP_SBY,
  NOPS,
  SICK,
  LAYOVER,
  UNKNOWN
}

DUTY_NATURE getDutyNatureFromString(String natureString) {
  return DUTY_NATURE.values.firstWhere((item) {
    return (item.toString() == natureString ||
        item.toString().substring(12) == natureString);
  }, orElse: () => DUTY_NATURE.UNKNOWN);
}

enum DUTY_STATUS { PLANNED, ON_GOING, DONE }

/// Representing a duty.
class Duty {
  DUTY_NATURE nature;
  String code;
  AwareDT startTime;
  AwareDT endTime;
  Airport startPlace;
  Airport endPlace;
  DUTY_STATUS status;
  List<Flight> _flights = [];

  bool acknowledge = false;

  Duty();

  Duty.fromJson(String jsonString) {
    Map<String, dynamic> jsonObject = json.decode(jsonString);

    nature = getDutyNatureFromString(jsonObject['nature']);
    code = jsonObject['code'];
    startTime = new AwareDT.fromString(jsonObject['startTime']);
    endTime = new AwareDT.fromString(jsonObject['endTime']);
    startPlace = new Airport.fromIata(jsonObject['startPlace']);
    endPlace = new Airport.fromIata(jsonObject['endPlace']);

    List<dynamic> jsonFlights = jsonObject['flights'];

    for (dynamic jsonFlight in jsonFlights) {
      _flights.add(new Flight.fromJson(json.encode(jsonFlight)));
    }
  }

  Duty.fromMap(Map<String, dynamic> mapObject) {
    nature = getDutyNatureFromString(mapObject['nature']);
    code = mapObject['code'];
    startTime = new AwareDT.fromString(mapObject['startTime']);
    endTime = new AwareDT.fromString(mapObject['endTime']);
    startPlace = new Airport.fromIata(mapObject['startPlace']);
    endPlace = new Airport.fromIata(mapObject['endPlace']);
    statusFromString = mapObject['status'];

    for (var flightMap in mapObject['flights']) {
      flights.add(new Flight.fromMap(flightMap));
    }
  }

  Duty.fromIobMap(Map<String, dynamic> iobMap) {
    RegExp flightRegExp = RegExp(r'\d{3}-\d{2}');

    /// Code
    code = iobMap['Trip'];

    /// Nature
    /// TODO: Refactor using 'iob_duty_codes.json'!
    if (code.contains('OFF') || code.contains('ROF')) {
      nature = DUTY_NATURE.OFF;
    } else if (code.contains('A/L') ||
        code.contains('PH LVE') ||
        code.contains('L/B')) {
      nature = DUTY_NATURE.LEAVE;
    } else if (code.contains('HS-AM') ||
        code.contains('HS-PM') ||
        code.contains('HS1') ||
        code.contains('HS2') ||
        code.contains('HS3') ||
        code.contains('HS4')) {
      nature = DUTY_NATURE.HOME_SBY;
    } else if (flightRegExp.hasMatch(code) || iobMap['Duty'] != '') {
      nature = DUTY_NATURE.FLIGHT;
    } else if (code.contains('NOPS')) {
      nature = DUTY_NATURE.NOPS;
    } else if (code.contains('330SD') || code.contains('330SC')) {
      nature = DUTY_NATURE.SIM;
    } else {
      Logger().w('[WARNING]: Unknown code [$code]');
      nature = DUTY_NATURE.UNKNOWN;
    }

    /// Start and end times
    startTime = new AwareDT.fromIobString(iobMap['Start']);
    endTime = new AwareDT.fromIobString(iobMap['End']);

    /// Start and end places
    startPlace = new Airport.fromIata(iobMap['From']);
    endPlace = new Airport.fromIata(iobMap['To']);
  }

  Duty.layover(
      {@required AwareDT startTime,
      @required AwareDT endTime,
      @required Airport airport}) {
    nature = DUTY_NATURE.LAYOVER;
    code = 'LAYOVER';
    this.startTime = startTime;
    this.endTime = endTime;
    startPlace = endPlace = airport;
  }

  String get id => nature.toString() + '_' + startTime.localDayString;

  Duration get duration {
    if (endTime == null || startTime == null) {
      return new Duration();
    }
    return endTime.difference(startTime);
  }

  String get statusAsString {
    if (status == DUTY_STATUS.PLANNED) return 'PLANNED';
    if (status == DUTY_STATUS.ON_GOING) return 'ON_GOING';
    if (status == DUTY_STATUS.DONE) return 'DONE';
    return 'UNKNOWN';
  }

  String get natureAsString {
    switch (nature) {
      case DUTY_NATURE.LEAVE:
        return 'LEAVE';
        break;
      case DUTY_NATURE.OFF:
        return 'OFF';
        break;
      case DUTY_NATURE.GROUND:
        return 'GROUND';
        break;
      case DUTY_NATURE.SIM:
        return 'SIM';
        break;
      case DUTY_NATURE.FLIGHT:
        return 'FLIGHT';
        break;
      case DUTY_NATURE.HOME_SBY:
        return 'HOME_SBY';
        break;
      case DUTY_NATURE.AIRP_SBY:
        return 'AIRP_SBY';
        break;
      case DUTY_NATURE.NOPS:
        return 'NOPS';
        break;
      case DUTY_NATURE.SICK:
        return 'SICK';
        break;
      case DUTY_NATURE.LAYOVER:
        return 'LAYOVER';
        break;
      case DUTY_NATURE.UNKNOWN:
        return 'UNKNOWN';
        break;
      default:
        return "";
    }
  }

  bool get isFlight => _flights.length != 0;

  bool get isStandby =>
      nature == DUTY_NATURE.AIRP_SBY || nature == DUTY_NATURE.HOME_SBY;

  bool get isWorkingDuty {
    if (nature == DUTY_NATURE.FLIGHT ||
        nature == DUTY_NATURE.SIM ||
        nature == DUTY_NATURE.GROUND) return true;
    return false;
  }

  bool get isLayover => nature == DUTY_NATURE.LAYOVER;

  List<Flight> get flights => _flights;

  Flight get firstFlight => isFlight ? flights.first : null;

  Flight get lastFlight => isFlight ? flights.last : null;

  FTL get ftl => isWorkingDuty ? FTL.fromDuty(this) : null;

  Rest get rest => ftl?.rest;

  FlightDutyPeriod get flightDutyPeriod => ftl.flightDutyPeriod;

  Duration get totalBlockTime {
    Duration result = Duration.zero;
    flights.forEach((flight) {
      result += flight.duration;
    });
    return result;
  }

  bool get involveRest {
    if (isWorkingDuty) return true;
    return false;
  }

  set statusFromString(String text) {
    if (text == 'PLANNED') status = DUTY_STATUS.PLANNED;
    if (text == 'ON_GOING') status = DUTY_STATUS.ON_GOING;
    if (text == 'DONE') status = DUTY_STATUS.DONE;
  }

  addFlight(Flight flight) {
    if (_flights.length == 0) startPlace = flight.startPlace;
    endPlace = flight.endPlace;
    _flights.add(flight);
  }

  /// Used for statistics building, splits duty and block times into 2 durations
  /// in case of Muscat day overlap. First value is before midninght, second is
  /// after. Result sent as a list of 1 or 2 items;
  List<Map<String, dynamic>> get statistics {
    var statisticsData = List<Map<String, dynamic>>();

    DateTime startTimeMuscat = startTime.utc.add(Duration(hours: 4));
    DateTime startDayMuscat = DateTime(
        startTimeMuscat.year, startTimeMuscat.month, startTimeMuscat.day);

    DateTime endTimeMuscat = endTime.utc.add(Duration(hours: 4));
    DateTime endDayMuscat =
        DateTime(endTimeMuscat.year, endTimeMuscat.month, endTimeMuscat.day);

    if (endDayMuscat.isAtSameMomentAs(startDayMuscat)) {
      // returns untouched duty and block times
      statisticsData.add({
        'day': startDayMuscat,
        'duty': isWorkingDuty ? duration : Duration.zero,
        'block': isFlight ? totalBlockTime : Duration.zero
      });
      return statisticsData;
    }

    DateTime midnightMuscat = startDayMuscat.add(Duration(hours: 24));

    statisticsData.add({ // first day
      'day': startDayMuscat,
      'duty': isWorkingDuty ? midnightMuscat.difference(startTimeMuscat) : Duration.zero,
      'block': Duration.zero
    });

    statisticsData.add({ // second day
      'day': endDayMuscat,
      'duty': isWorkingDuty ? endTimeMuscat.difference(midnightMuscat) : Duration.zero,
      'block': Duration.zero
    });

    // Block time calculations
    for (var flight in flights) {
      DateTime startFlightTimeMuscat =
          flight.startTime.utc.add(Duration(hours: 4));
      DateTime endFlightTimeMuscat =
          flight.endTime.utc.add(Duration(hours: 4));

      if (endFlightTimeMuscat.isBefore(midnightMuscat)) {
        statisticsData[0]['block'] += totalBlockTime;
      } else if (startFlightTimeMuscat.isAfter(midnightMuscat)) {
        statisticsData[1]['block'] += totalBlockTime;
      } else {
        statisticsData[0]['block'] +=
            midnightMuscat.difference(startFlightTimeMuscat);
        statisticsData[1]['block'] +=
            endFlightTimeMuscat.difference(midnightMuscat);
      }
    }

    return statisticsData;
  }

  String toString() {
    String result = "|";

    nature == null ? result += 'UNKNOWN  |' : result += nature.toString() + '|';
    code == null ? result += 'UNKNOWN  |' : result += code + '|';
    startPlace == null ? result += 'XXX|' : result += startPlace.IATA + '|';
    startTime == null
        ? result += 'DDMMMYYYY HH:MM|'
        : result += startTime.toString() + '|';
    endPlace == null ? result += 'XXX|' : result += endPlace.IATA + '|';
    endTime == null
        ? result += 'DDMMMYYYY HH:MM|'
        : result += endTime.toString() + '|';
    result += durationToString(duration) + '|';
    result += statusAsString + '|';

    for (Flight flight in _flights) {
      result += '\n' + flight.toString();
    }

    return result;
  }

  // JSON stuff

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> flightMaps = new List<Map<String, dynamic>>();

    for (Flight flight in flights) {
      flightMaps.add(flight.toMap());
    }

    Map<String, dynamic> dutyMap = {
      'nature': nature.toString(),
      'code': code,
      'startTime': startTime.toString(),
      'endTime': endTime.toString(),
      'startPlace': startPlace.IATA,
      'endPlace': endPlace.IATA,
      'status': statusAsString,
      'flights': flightMaps,
    };

    return dutyMap;
  }

  String toJson() {
    return json.encode(this.toMap());
  }
}
