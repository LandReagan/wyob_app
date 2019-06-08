import 'dart:convert';

import 'package:wyob/utils/DateTimeUtils.dart';

import 'Airport.dart' show Airport;
import 'package:wyob/utils/DateTimeUtils.dart' show AwareDT, durationToString;

/// This class represents a flight
class Flight {

  AwareDT startTime;
  AwareDT endTime;
  Airport startPlace;
  Airport endPlace;
  String flightNumber;

  Duration get duration => endTime.difference(startTime);
  String get durationString {
    return durationToStringHM(duration);
  }

  Flight.fromMap(Map<String, dynamic> mapObject) {
    startTime = new AwareDT.fromString(mapObject['startTime']);
    endTime = new AwareDT.fromString(mapObject['endTime']);
    startPlace = new Airport.fromIata(mapObject['startPlace']);
    endPlace = new Airport.fromIata(mapObject['endPlace']);
    flightNumber = mapObject['flightNumber'];
  }

  factory Flight.fromJson(String jsonString) {
    return Flight.fromMap(jsonDecode(jsonString));
  }

  Flight.fromIobMap(Map<String, dynamic> iobMap) {
    startTime = new AwareDT.fromIobString(iobMap['Start']);
    endTime = new AwareDT.fromIobString(iobMap['End']);
    startPlace = new Airport.fromIata(iobMap['From']);
    endPlace = new Airport.fromIata(iobMap['To']);
    flightNumber = iobMap['Flight'];
  }

  String toJson() {
    return json.encode(this.toMap());
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> flightMap = {
      'startTime': startTime.toString(),
      'endTime': endTime.toString(),
      'startPlace': startPlace.IATA,
      'endPlace': endPlace.IATA,
      'flightNumber': flightNumber,
    };
    return flightMap;
  }

  String toString() {

    String result = "|";

    flightNumber == null ? result += 'UNKNOWN  |' : result += flightNumber + '|';
    startPlace == null ? result += 'XXX|' : result += startPlace.IATA + '|';
    startTime == null ?
    result += 'DDMMMYYYY HH:MM|' : result += startTime.toString() + '|';
    endPlace == null ? result += 'XXX|' : result += endPlace.IATA + '|';
    endTime == null ?
    result += 'DDMMMYYYY HH:MM|' : result += endTime.toString() + '|';
    result += durationToString(duration) + '|';

    return result;
  }
}
