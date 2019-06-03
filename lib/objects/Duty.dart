import 'dart:convert' show json;

import 'package:wyob/objects/Airport.dart' show Airport;
import 'package:wyob/objects/FTL.dart';
import 'package:wyob/objects/Flight.dart' show Flight;
import 'package:wyob/utils/DateTimeUtils.dart' show AwareDT, durationToString;


const List<String> DutyNature = [
  'LEAVE',
  'OFF',
  'GROUND',
  'SIM',
  'FLIGHT',
  'STDBY',
  'NOPS',
  'SICK',
];

enum DUTY_STATUS {
  PLANNED,
  ON_GOING,
  DONE
}

/// Representing a duty.
class Duty {

  String _nature;
  String _code;
  AwareDT _startTime;
  AwareDT _endTime;
  Airport _startPlace;
  Airport _endPlace;
  DUTY_STATUS _status;
  List<Flight> _flights = [];

  bool acknowledge = false;

  Duty();

  Duty.fromJson(String jsonString) {

    Map<String, String> jsonObject = json.decode(jsonString);

    _nature = jsonObject['nature'];
    _code = jsonObject['code'];
    _startTime = new AwareDT.fromIobString(jsonObject['startTime']);
    _endTime = new AwareDT.fromIobString(jsonObject['endTime']);
    _startPlace = new Airport.fromIata(jsonObject['startPlace']);
    _endPlace = new Airport.fromIata(jsonObject['endPlace']);

    List<Map<String, String>> jsonFlights = json.decode(jsonObject['flights']);

    for (Map<String, String> jsonFlight in jsonFlights) {
      _flights.add(new Flight.fromJson(json.encode(jsonFlight)));
    }
  }

  Duty.fromMap(Map<String, dynamic> map) {

    nature = map['nature'];
    code = map['code'];
    startTime = new AwareDT.fromString(map['startTime']);
    endTime = new AwareDT.fromString(map['endTime']);
    startPlace = new Airport.fromIata(map['startPlace']);
    endPlace = new Airport.fromIata(map['endPlace']);
    statusFromString = map['status'];

    for (var flightMap in map['flights']) {
      flights.add(new Flight.fromMap(flightMap));
    }
  }

  Duty.fromIobMap(Map<String, String> iobMap) {

    RegExp flightRegExp = RegExp(r'\d{3}-\d{2}');

    /// Code
    _code = iobMap['Trip'];

    /// Nature
    /// TODO: Refactor using 'iob_duty_codes.json'!
    if (
        code.contains('OFF') ||
        code.contains('ROF')
        ) {
      _nature = 'OFF';
    } else if (
        code.contains('A/L') ||
        code.contains('PH LVE') ||
        code.contains('L/B')
        ) {
      _nature = 'LEAVE';
    } else if (
        code.contains('HS-AM') ||
        code.contains('HS-PM') ||
        code.contains('HS1') ||
        code.contains('HS2') ||
        code.contains('HS3') ||
        code.contains('HS4')
      ) {
      _nature = 'STDBY';
    } else if (flightRegExp.hasMatch(code) || iobMap['Duty'] != '') {
      _nature = 'FLIGHT';
    } else if (code.contains('NOPS')) {
      _nature = 'NOPS';
    } else if (code.contains('330SD') || code.contains('330SC')) {
      _nature = 'SIM';
    } else {
      print('[WARNING]: Unknown code [$code]');
      _nature = 'UNKNOWN';
    }

    /// Start and end times
    startTime = new AwareDT.fromIobString(iobMap['Start']);
    endTime = new AwareDT.fromIobString(iobMap['End']);

    /// Start and end places
    startPlace = new Airport.fromIata(iobMap['From']);
    endPlace = new Airport.fromIata(iobMap['To']);
  }

  String get id => nature + '_' + startTime.localDayString;
  String get nature => _nature;
  String get code => _code;
  AwareDT get startTime => _startTime;
  AwareDT get endTime => _endTime;
  Airport get startPlace => _startPlace;
  Airport get endPlace => _endPlace;
  Duration get duration {
    if (_endTime == null || _startTime == null) { return new Duration(); }
    return _endTime.difference(_startTime);
  }
  DUTY_STATUS get status => _status;
  String get statusAsString {
    if (_status == DUTY_STATUS.PLANNED) return 'PLANNED';
    if (_status == DUTY_STATUS.ON_GOING) return 'ON_GOING';
    if (_status == DUTY_STATUS.DONE) return 'DONE';
    return 'UNKNOWN';
  }
  bool get isFlight => _flights.length != 0;
  bool get isWorkingDuty {
    if (nature == 'FLIGHT' || nature == 'SIM' || nature == 'GROUND')
      return true;
    return false;
  }
  List<Flight> get flights => _flights;
  Flight get firstFlight => isFlight ? flights.first : null;
  Flight get lastFlight => isFlight ? flights.last : null;

  FTL get ftl => FTL(this);
  Rest get rest => ftl.rest;
  FlightDutyPeriod get flightDutyPeriod => ftl.flightDutyPeriod;

  Duration get totalBlockTime {
    Duration result = Duration.zero;
    flights.forEach((flight) {
      result += flight.duration;
    });
    return result;
  }

  bool get involveRest {
    if (this.nature == 'FLIGHT' || this.nature == 'SIM'
        || this.nature == 'GROUND') {
      return true;
    }
    return false;
  }

  set nature (String nature) {
    DutyNature.contains(nature) ? _nature = nature : _nature = "UNKNOWN";
  }
  set code (String txt) => _code = txt;
  set startTime (AwareDT time) => _startTime = time;
  set endTime (AwareDT time) => _endTime = time;
  set startPlace (Airport airport) => _startPlace = airport;
  set endPlace (Airport airport) => _endPlace = airport;
  set status (DUTY_STATUS status) => _status = status;
  set statusFromString (String text) {
    if (text == 'PLANNED') _status = DUTY_STATUS.PLANNED;
    if (text == 'ON_GOING') _status = DUTY_STATUS.ON_GOING;
    if (text == 'DONE') _status = DUTY_STATUS.DONE;
  }

  addFlight(Flight flight) {
    if (_flights.length == 0) _startPlace = flight.startPlace;
    _endPlace = flight.endPlace;
    _flights.add(flight);
  }

  String toString() {

    String result = "|";

    nature == null ? result += 'UNKNOWN  |' : result += nature + '|';
    code == null ? result += 'UNKNOWN  |' : result += code + '|';
    startPlace == null ? result += 'XXX|' : result += startPlace.IATA + '|';
    startTime == null ?
      result += 'DDMMMYYYY HH:MM|' : result += startTime.toString() + '|';
    endPlace == null ? result += 'XXX|' : result += endPlace.IATA + '|';
    endTime == null ?
      result += 'DDMMMYYYY HH:MM|' : result += endTime.toString() + '|';
    result += durationToString(duration) + '|';
    result += statusAsString + '|';

    for (Flight flight in _flights) {
      result += '\n' + flight.toString();
    }

    return result;
  }

  // JSON stuff

  Map<String, dynamic> toMap() {

    List<Map<String, String>> flightMaps = new List<Map<String, String>>();

    for (Flight flight in flights) {
      flightMaps.add(flight.toMap());
    }

    Map<String, dynamic> dutyMap = {
      'nature': _nature,
      'code': _code,
      'startTime' : _startTime.toString(),
      'endTime': _endTime.toString(),
      'startPlace': _startPlace.IATA,
      'endPlace': _endPlace.IATA,
      'status': statusAsString,
      'flights': flightMaps,
    };

    return dutyMap;
  }

  String toJson() {
    return json.encode(this.toMap());
  }
}
