List<String> months = [
  "Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

/// This function returns a properly formatted DateTime.
/// Format: DDMmmYYYY HH:MM
/// with month as the standard 3 letters (e.g. JAN, FEB, MAR, etc.).
String dateTimeToString(DateTime datetime) {

  String day = datetime.day.toString();
  if (day.length < 2) { day = "0" + day; }
  String month = months[datetime.month - 1];
  String year = datetime.year.toString();
  String hour = datetime.hour.toString();
  if (hour.length < 2) { hour = "0" + hour; }
  String minute = datetime.minute.toString();
  if (minute.length < 2) { minute = "0" + minute; }

  return day + month + year + " " + hour + ":" + minute;
}

/// This function returns a DateTime object out of a String.
/// Format: DDMmmYYYY HH:MM
/// with month as the standard 3 letters (e.g. JAN, FEB, MAR, etc.).
DateTime stringToDateTime(String txt) {

  RegExp regexp = new RegExp(
    r'(\d{2})(\w{3})(\d{4})\s(\d{2}):(\d{2})'
  );

  var match = regexp.firstMatch(txt);

  int day = int.parse(match.group(1));
  String monthString = match.group(2);
  int month = months.indexOf(monthString) + 1;
  int year = int.parse(match.group(3));
  int hour = int.parse(match.group(4));
  int minute = int.parse(match.group(5));

  return new DateTime(year, month, day, hour, minute);
}

String durationToString(Duration duration) {

  String sign = duration.isNegative ? "-" : "+";
  String hours = duration.abs().inHours.toString();
  String minutes = (duration.abs().inMinutes % 60).toString();
  if (hours.length < 2) hours = "0" + hours;
  if (minutes.length < 2) minutes = "0" + minutes;

  return sign + hours + ":" + minutes;
}

String durationToStringHM(Duration duration) {
  if (duration == null) return null;
  String result = '';
  duration >= Duration.zero ? result += '' : result += '-';
  if (duration.inHours.abs() < 10) result += '0';
  result += duration.inHours.abs().toString() + 'h';
  int minutes = duration.inMinutes.abs() - duration.inHours.abs() * 60;
  if (minutes < 10) result += '0';
  result += minutes.toString() + 'm';
  return result;
}

Duration stringToDuration(String txt) {

  RegExp durationRegExp = new RegExp(
    r"([\+|-])(\d{2}):(\d{2})"
  );

  var match = durationRegExp.firstMatch(txt);

  Duration duration = new Duration(
    hours: int.parse(match.group(2)),
    minutes: int.parse(match.group(3))
  );

  if (match.group(1) == '-') { duration *= -1; }

  return duration;
}

class AwareDT extends Object{

  DateTime _utc;
  DateTime _loc;

  AwareDT.fromDateTimes(DateTime locDT, DateTime utcDT) {
    _utc = utcDT;
    _loc = locDT;
  }

  AwareDT.now() {
    _loc = DateTime.now();
    _utc = DateTime.now().toUtc();
  }

  /// fromString from our format: DDmmmYYYY HH:MM +HH:MM
  AwareDT.fromString(String txt) {

    RegExp txtRegExp = new RegExp(
        r'(\d{2}\w{3}\d{4}\s+\d{2}:\d{2})\s+([\+|-]\d{2}:\d{2})'
    );

    var match = txtRegExp.firstMatch(txt);

    _loc = stringToDateTime(match.group(1));
    _utc = _loc.subtract(stringToDuration(match.group(2)));
  }

  /// Special constructor with an IOB string.
  /// Format: DDMMMYYYY HH:MM (HH:MM) e.g. 01Jul2018 21:05 (20:05)
  AwareDT.fromIobString(String txt) {

    RegExp iobStringRegExp = new RegExp(
        r'(\d{2})(\w{3})(\d{4})\s+(\d{2}):(\d{2})\s\((\d{2}):(\d{2})\)'
    );

    var match = iobStringRegExp.firstMatch(txt);

    int day = int.parse(match.group(1));
    int month = months.indexOf(match.group(2)) + 1;
    int year = int.parse(match.group(3));
    int hours = int.parse(match.group(4));
    int minutes = int.parse(match.group(5));
    int gmtHours = int.parse(match.group(6));
    int gmtMinutes = int.parse(match.group(7));

    _loc = new DateTime(year, month, day, hours, minutes);
    _utc = new DateTime(year, month, day, gmtHours, gmtMinutes);

    if (_loc.difference(_utc) > new Duration(hours: 12)) {
      _utc = _utc.add(new Duration(days: 1));
    }

    if (_loc.difference(_utc) < new Duration(hours: -12)) {
      _utc = _utc.add(new Duration(days: -1));
    }
  }

  DateTime get utc => _utc;
  DateTime get loc => _loc;
  Duration get gmtDiff {
    if (_utc == null || _loc == null) {
      return new Duration(minutes: 0);
    }
    return _loc.difference(_utc);
  }

  String get localDayString {
    String day = _loc.day.toString();
    if (day.length < 2) { day = "0" + day; }
    String month = months[_loc.month - 1];
    String year = _loc.year.toString();
    return day + ' ' + month + ' ' + year;
  }

  String get localTimeString {
    String hour = _loc.hour.toString();
    if (hour.length < 2) { hour = "0" + hour; }
    String minute = _loc.minute.toString();
    if (minute.length < 2) { minute = "0" + minute; }
    return hour + ":" + minute;
  }

  String get utcDayString {
    String day = _utc.day.toString();
    if (day.length < 2) { day = "0" + day; }
    String month = months[_utc.month - 1];
    String year = _utc.year.toString();
    return day + ' ' + month + ' ' + year;
  }

  String get utcTimeString {
    String hour = _utc.hour.toString();
    if (hour.length < 2) { hour = "0" + hour; }
    String minute = _utc.minute.toString();
    if (minute.length < 2) { minute = "0" + minute; }
    return hour + ":" + minute + "z";
  }

  Duration difference (AwareDT before) {
    return _utc.difference(before.utc);
  }

  Duration timeZoneDifference(AwareDT other) {
    return this.gmtDiff - other.gmtDiff;
  }

  AwareDT add(Duration duration) {
    DateTime locDT = this._loc.add(duration);
    DateTime utcDT = this._utc.add(duration);
    return AwareDT.fromDateTimes(locDT, utcDT);
  }

  AwareDT subtract(Duration duration) {
    DateTime locDT = this._loc.subtract(duration);
    DateTime utcDT = this._utc.subtract(duration);
    return AwareDT.fromDateTimes(locDT, utcDT);
  }

  // Operators
  bool operator >=(AwareDT other) {
    return this.utc.difference(other.utc) >= Duration.zero;
  }

  bool operator <=(AwareDT other) {
    return this.utc.difference(other.utc) <= Duration.zero;
  }

  bool operator >(AwareDT other) {
    return this.utc.difference(other.utc) > Duration.zero;
  }

  bool operator <(AwareDT other) {
    return this.utc.difference(other.utc) < Duration.zero;
  }

  /// toString to reflect our format: DDMmmYYYY HH:MM +HH:MM
  @override
  String toString() {

    String locDateTimeString = dateTimeToString(_loc);
    String gmtDiffString = durationToString(gmtDiff);

    return locDateTimeString + " " + gmtDiffString;
  }
}
