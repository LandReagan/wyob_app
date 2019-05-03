import 'package:wyob/WyobException.dart';
import 'package:wyob/utils/DateTimeUtils.dart';

/// Used to calculate all FTLs.
class FTL {

  AwareDT _reporting;
  int _numberOfLandings;

  Duration get maxFlightDutyLength => _getMaxFlightDutyLength();

  set reporting (AwareDT reporting) => _reporting = reporting;
  set numberOfLandings (int number) => _numberOfLandings = number;

  Duration _getMaxFlightDutyLength() {

    if (_reporting == null) throw WyobExceptionFtlIncomplete(
        'Reporting time missing, calculation impossible!');

    if (_numberOfLandings == null) throw WyobExceptionFtlIncomplete(
        'Number of landings missing, calculation impossible!');

    int reportingHour = _reporting.loc.hour;
    Duration maxFDP;
    if (reportingHour >= 7 && reportingHour < 12) {
      maxFDP = Duration(hours: 14);
    } else if (reportingHour >= 12 && reportingHour < 14) {
      maxFDP = Duration(hours: 13, minutes: 30);
    } else if (reportingHour >= 14 && reportingHour < 16) {
      maxFDP = Duration(hours: 13);
    } else if (reportingHour >= 16 && reportingHour < 18) {
      maxFDP = Duration(hours: 12, minutes: 30);
    } else if (reportingHour >= 18 || reportingHour < 4) {
      maxFDP = Duration(hours: 12);
    } else if (reportingHour >= 4 && reportingHour < 5) {
      maxFDP = Duration(hours: 12, minutes: 30);
    } else if (reportingHour >= 5 && reportingHour < 6) {
      maxFDP = Duration(hours: 13);
    } else {
      maxFDP = Duration(hours: 13, minutes: 30);
    }

    for (int i = 3; i <= _numberOfLandings; i++) {
      maxFDP -= Duration(minutes: 45);
    }
    if (maxFDP < Duration(hours: 9)) maxFDP = Duration(hours: 9);

    return maxFDP;
  }
}

/// Convenience class to deal with "periods", i.e. time intervals having
/// a [start] and an [end], whom attributes we can derive [duration]s.
class Period {

  DateTime start;
  DateTime end;

  Period({DateTime from, DateTime to}) : start = from, end = to;

  Duration get duration {
    if (end != null && start != null) return end.difference(start);
    return null;
  }

  String get durationString {
    if (this.duration == null) return null;

    int hours = this.duration.inHours;
    int minutes = (this.duration - Duration(hours: this.duration.inHours)).inMinutes;

    String hoursString = hours.toString();
    if (hoursString.length == 1) hoursString = '0' + hoursString;
    String minutesString = minutes.toString();
    if (minutesString.length == 1) minutesString = '0' + minutesString;

    return hoursString + ':' + minutesString;
  }
}
