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

  Flight.fromMap(Map<String, dynamic> map) {
    startTime = new AwareDT.fromString(map['startTime']);
    endTime = new AwareDT.fromString(map['endTime']);
    startPlace = new Airport.fromIata(map['startPlace']);
    endPlace = new Airport.fromIata(map['endPlace']);
    flightNumber = map['flightNumber'];
  }

  Flight.fromJson(String jsonString) {

    Map<String, dynamic> jsonObject = json.decode(jsonString);

    startTime = new AwareDT.fromString(jsonObject['startTime']);
    endTime = new AwareDT.fromString(jsonObject['endTime']);
    startPlace = new Airport.fromIata(jsonObject['startPlace']);
    endPlace = new Airport.fromIata(jsonObject['endPlace']);
    flightNumber = jsonObject['flightNumber'];
  }

  Flight.fromIobMap(Map<String, String> iobMap) {
    startTime = new AwareDT.fromIobString(iobMap['Start']);
    endTime = new AwareDT.fromIobString(iobMap['End']);
    startPlace = new Airport.fromIata(iobMap['From']);
    endPlace = new Airport.fromIata(iobMap['To']);
    flightNumber = iobMap['Flight'];
  }

  String toJson() {
    return json.encode(this.toMap());
  }

  Map<String, String> toMap() {
    Map<String, String> flightMap = {
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
