import 'dart:convert' show json;

import 'Airport.dart' show Airport;
import 'Flight.dart' show Flight;
import 'DateTimeUtils.dart';

const List<String> DutyNature = [
  'LEAVE',
  'OFF',
  'GROUND',
  'SIMULATOR',
  'FLIGHT',
  'STANDBY',
];

/// Duty class
/// Representing a duty.
class Duty {

  String _nature;
  String _code;
  AwareDT _startTime;
  AwareDT _endTime;
  Airport _startPlace;
  Airport _endPlace;
  List<Flight> _flights = [];

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

    for (var flightMap in map['flights']) {
      flights.add(new Flight.fromMap(flightMap));
    }
  }

  Duty.fromIobMap(Map<String, String> iobMap) {

    RegExp flightRegExp = new RegExp(r'\d{3}-\d{2}');

    /// Code
    _code = iobMap['Trip'];

    /// Nature
    if (
        code.contains('OFF') ||
        code.contains('ROF')
        ) {
      _nature = 'OFF';
    } else if (
        code.contains('A/L') ||
        code.contains('PH LVE')
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
      _nature = 'STANDBY';
    } else if (flightRegExp.hasMatch(code) || iobMap['Duty'] != '') {
      _nature = 'FLIGHT';
    }

    /// Start and end times
    startTime = new AwareDT.fromIobString(iobMap['Start']);
    endTime = new AwareDT.fromIobString(iobMap['End']);

    /// Start and end places
    startPlace = new Airport.fromIata(iobMap['From']);
    endPlace = new Airport.fromIata(iobMap['To']);
  }

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
  List<Flight> get flights => _flights;

  //TODO: Add convenient setters with other types if needed.
  set nature (String nature) {
    DutyNature.contains(nature) ? _nature = nature : _nature = "UNKNOWN";
  }
  set code (String txt) => _code = txt;
  set startTime (AwareDT time) => _startTime = time;
  set endTime (AwareDT time) => _endTime = time;
  set startPlace (Airport airport) => _startPlace = airport;
  set endPlace (Airport airport) => _endPlace = airport;

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
    result += DurationToString(duration) + '|';

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
      'flights': flightMaps,
    };

    return dutyMap;
  }

  String toJson() {

    return json.encode(this.toMap());
  }
}