class Airport {

  String _IATA;
  String _ICAO;
  String _fullName;
  // TODO: implement time zone

  Airport.fromIata(String txt) {
    if (txt.length == 3) { this._IATA = txt; }
  }

  String get IATA => _IATA != null ? _IATA : "???";
  String get ICAO => _ICAO;
  String get fullName => _fullName;

  set IATA (String txt) {
    if (txt.length == 3) {_IATA = txt; }
    else {
      // TODO: Error management
    }
  }

  set ICAO (String txt) {
    if (txt.length == 4) {_ICAO = txt; }
    else {
      // TODO: Error management
    }
  }

  set fullName (String txt) => _fullName = txt;
}