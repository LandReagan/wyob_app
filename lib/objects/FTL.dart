import 'package:wyob/utils/DateTimeUtils.dart';
import 'package:wyob/objects/Duty.dart';

/// Used to calculate all FTLs. It is linked to a Duty.
class FTL {

  final Duty _duty;

  FTL(this._duty);

  FlightDutyPeriod get flightDutyPeriod {

    if (_duty.nature != 'FLIGHT') return null;

    var fdp = FlightDutyPeriod(
      reporting: _duty.startTime,
      onBlocks: _duty.endTime,
      numberOfLandings: _duty.flights.length
    );

    return fdp;
  }

  Rest get rest => _duty.involveRest ? Rest.fromDuty(_duty) : null;

  String toString() {
    return '|FTL data|\n==>' + flightDutyPeriod.toString() +
      '\n==>' + rest.toString();
  }
}

/// Convenience class to deal with "periods", i.e. time intervals having
/// a [start] and an [end], whom attributes we can derive [duration]s.
class Period {

  AwareDT start;
  AwareDT end;

  Period({AwareDT from, AwareDT to}) : start = from, end = to;

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

/// As defined in OM-A chapter 7, from reporting time to on-blocks time
class FlightDutyPeriod extends Period {

  int numberOfLandings;

  FlightDutyPeriod({AwareDT reporting, AwareDT onBlocks, int numberOfLandings}) {
    this.start = reporting;
    this.end = onBlocks;
    this.numberOfLandings = numberOfLandings;
  }

  FlightDutyPeriod.fromDuty(Duty duty) {
    this.start = duty.startTime;
    this.end = duty.lastFlight.endTime;
    this.numberOfLandings = duty.flights.length;
  }

  set reporting(AwareDT time) => this.start = time;
  set onBlocks(AwareDT time) => this.end = time;

  AwareDT get reporting => this.start;
  AwareDT get onBlocks => this.end;

  Duration get maxFlightDutyPeriodLength => this._getMaxFlightDutyLength();
  AwareDT get maxFlightDutyPeriodEndTime =>
      this.start.add(this.maxFlightDutyPeriodLength);
  Period get maxFlightDutyPeriod =>
      Period(from: this.start, to: maxFlightDutyPeriodEndTime);

  Duration get extendedFlightDutyPeriodLength =>
      this.maxFlightDutyPeriodLength + Duration(hours: 2);
  AwareDT get extendedFlightDutyPeriodEndTime =>
      this.start.add(this.extendedFlightDutyPeriodLength);
  Period get extendedFlightDutyPeriod =>
      Period(from: this.start, to: extendedFlightDutyPeriodEndTime);

  bool get isLegal => this.end < this.extendedFlightDutyPeriodEndTime;
  bool get extensionRequired => this.end > this.maxFlightDutyPeriodEndTime;

  Duration _getMaxFlightDutyLength() {

    if (this.start == null) return null;

    if (this.numberOfLandings == null) return null;

    int reportingHour = this.start.loc.hour;
    Duration maxFDPLength;
    if (reportingHour >= 7 && reportingHour < 12) {
      maxFDPLength = Duration(hours: 14);
    } else if (reportingHour >= 12 && reportingHour < 14) {
      maxFDPLength = Duration(hours: 13, minutes: 30);
    } else if (reportingHour >= 14 && reportingHour < 16) {
      maxFDPLength = Duration(hours: 13);
    } else if (reportingHour >= 16 && reportingHour < 18) {
      maxFDPLength = Duration(hours: 12, minutes: 30);
    } else if (reportingHour >= 18 || reportingHour < 4) {
      maxFDPLength = Duration(hours: 12);
    } else if (reportingHour >= 4 && reportingHour < 5) {
      maxFDPLength = Duration(hours: 12, minutes: 30);
    } else if (reportingHour >= 5 && reportingHour < 6) {
      maxFDPLength = Duration(hours: 13);
    } else {
      maxFDPLength = Duration(hours: 13, minutes: 30);
    }

    for (int i = 3; i <= this.numberOfLandings; i++) {
      maxFDPLength -= Duration(minutes: 45);
    }
    if (maxFDPLength < Duration(hours: 9)) maxFDPLength = Duration(hours: 9);

    return maxFDPLength;
  }

  String toString() {
    return '|FDP|start: ' + this.start.toString() +
            '|end: ' + this.end.toString() +
            '|duration: ' + this.durationString;
  }
}

class Rest extends Period {

  Rest.fromDuty(Duty duty) {
    if (!duty.involveRest) {
      this.start = duty.endTime;
      this.end = duty.endTime;
      return;
    }

    // Start time is duty end time (30 minutes after blocks on time)
    this.start = AwareDT.fromDateTimes(duty.endTime.loc, duty.endTime.utc);

    // Rest time is either 11 hours or total duty time whichever is longer.
    Duration dutyDuration = duty.endTime.utc.difference(duty.startTime.utc);
    Duration stdRestDuration = Duration(hours: 11);
    Duration restDuration =
    dutyDuration > stdRestDuration ? dutyDuration : stdRestDuration;

    this.end = this.start.add(restDuration);
  }

  String toString() {
    return '|REST|from: ' + this.start.toString() +
            '|to: ' + this.end.toString() + '|duration: ' + this.durationString;
  }
}
