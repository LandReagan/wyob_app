class Airport {

  String _iata;
  String _icao;

  Airport.fromIata(String txt) {
    if (txt.length == 3) { this._iata = txt; }
  }

  String get IATA => _iata != null ? _iata : "???"; // ignore: non_constant_identifier_names
  String get ICAO => _icao; // ignore: non_constant_identifier_names

  set IATA (String txt) { // ignore: non_constant_identifier_names
    if (txt.length == 3) {_iata = txt; }
    else {
      // TODO: Error management
    }
  }

  set ICAO (String txt) { // ignore: non_constant_identifier_names
    if (txt.length == 4) {_icao = txt; }
    else {
      // TODO: Error management
    }
  }
}
