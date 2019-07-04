import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wyob/utils/DateTimeUtils.dart';
import 'package:wyob/objects/Duty.dart';
import 'package:wyob/widgets/StandbyTypeWidget.dart';

/// Used to calculate all FTLs. It can be constructed from a Duty or from the
/// widget input, with optional previous standby data.
class FTL {

  AwareDT reporting;
  int numberOfLandings;
  AwareDT onBlocks;
  AwareDT offDuty;

  AwareDT standbyStart;
  STANDBY_TYPE standbyType;

  FTL.fromDuty(Duty duty, {Duty previous}) {
    // todo: add airport standby
    if (previous != null && previous.nature == DUTY_NATURE.HOME_SBY) {
      standbyStart = previous.startTime;
      standbyType = STANDBY_TYPE.HOME;
    } else if (previous != null && previous.nature == DUTY_NATURE.AIRP_SBY) {
      standbyStart = previous.startTime;
      standbyType = STANDBY_TYPE.AIRPORT;
    }
    reporting = duty.startTime;
    if (duty.isFlight) {
      onBlocks = duty.lastFlight.endTime;
      numberOfLandings = duty.flights.length;
    }
    offDuty = duty.endTime;
  }

  FTL.fromWidget({
        @required DateTime reportingDate,
        @required TimeOfDay reportingTime,
        @required Duration reportingGMTDiff,
        @required int numberOfLandings,
        @required TimeOfDay onBlocks,
        @required Duration onBlocksGMTDiff,
        TimeOfDay standbyStartTime,
        STANDBY_TYPE standbyType,
  }) {
    // STAND BY
    if (standbyStartTime != null) {
      DateTime standbyStartLoc = reportingDate;
      standbyStartLoc = standbyStartLoc.add(
        Duration(hours: standbyStartTime.hour, minutes: standbyStartTime.minute));
      DateTime standbyStartUtc = standbyStartLoc.subtract(reportingGMTDiff);
      this.standbyStart = AwareDT.fromDateTimes(standbyStartLoc, standbyStartUtc);
    }

    if (standbyType != null) this.standbyType = standbyType;

    // REPORTING
    DateTime reportingLoc = reportingDate;
    reportingLoc = reportingLoc.add(
        Duration(hours: reportingTime.hour, minutes: reportingTime.minute));
    DateTime reportingUtc = reportingLoc.subtract(reportingGMTDiff);
    this.reporting = AwareDT.fromDateTimes(reportingLoc, reportingUtc);
    if (standbyStart != null && reporting < standbyStart)
        reporting = reporting.add(Duration(hours: 24));

    // NUMBER OF LANDINGS
    this.numberOfLandings = numberOfLandings;

    // ON BLOCKS
    DateTime onBlocksLoc = reportingDate;
    onBlocksLoc = onBlocksLoc.add(
        Duration(hours: onBlocks?.hour, minutes: onBlocks.minute));
    DateTime onBlocksUtc = onBlocksLoc.subtract(onBlocksGMTDiff);
    this.onBlocks = AwareDT.fromDateTimes(onBlocksLoc, onBlocksUtc);
    if (this.reporting > this.onBlocks)
        this.onBlocks = this.onBlocks.add(Duration(hours: 24));

    this.offDuty = this.onBlocks.add(Duration(minutes: 30));
  }

  bool get isStandby => standbyStart != null;

  /// returns additional duration in case of previous standby or Duration.zero
  /// if none. Never returns null!
  Duration get standbyCorrection {

    int correctionInMinutes = 0;

    if (standbyStart != null &&
        reporting.difference(standbyStart) > Duration(hours: 4) &&
        standbyType == STANDBY_TYPE.HOME) {
      correctionInMinutes = (reporting.difference(standbyStart) -
          Duration(hours: 4)).inMinutes;
    } else if (standbyStart != null && standbyType == STANDBY_TYPE.AIRPORT) {
      correctionInMinutes = reporting.difference(standbyStart).inMinutes;
    }

    correctionInMinutes = (correctionInMinutes / 2).floor();
    if (correctionInMinutes == 0) return Duration.zero;
    return Duration(minutes: correctionInMinutes);
  }

  FlightDutyPeriod get flightDutyPeriod {

    if (this.numberOfLandings == 0 || !this.isComplete) return null;

    return FlightDutyPeriod(
      reporting: this.reporting,
      onBlocks: this.onBlocks,
      correction: this.standbyCorrection,
      numberOfLandings: numberOfLandings
    );
  }

  Rest get rest {
    if (!this.isComplete) return null;
    if (reporting != null && offDuty != null) return Rest(reporting, offDuty, addition: standbyCorrection);
    return Rest.fromFTLInputs(reporting, onBlocks);
  }

  DutyPeriod get dutyPeriod {
    if (!this.isComplete) return null;
    return DutyPeriod(start: reporting, end: offDuty, addition: standbyCorrection);
  }

  bool get isComplete {
    if (reporting != null && offDuty != null) return true;
    if (reporting != null && numberOfLandings != null && onBlocks != null) return true;
    return false;
  }

  String toString() {
    if (!this.isComplete) return 'INVALID FTL OBJECT';
    return '|FTL data|\n==>' + flightDutyPeriod.toString() +
      '\n==>' + rest.toString();
  }
}

/// Convenience class to deal with "periods", i.e. time intervals having
/// a [start] and an [end], whom attributes we can derive [duration]s.
class Period {

  AwareDT start;
  AwareDT end;
  Duration addition;

  Period(
      {AwareDT from, AwareDT to, Duration addition}
  ) : start = from, end = to, addition = addition;

  Duration get duration {
    Duration result;
    if (end != null && start != null) {
      result = end.difference(start);
      if (addition != null) result += addition;
    }
    return result;
  }

  String get durationString => durationToStringHM(duration);
}

/// As defined in OM-A chapter 7, from reporting time to on-blocks time
class FlightDutyPeriod extends Period {

  int numberOfLandings;
  Duration correction;

  FlightDutyPeriod({AwareDT reporting, AwareDT onBlocks, int numberOfLandings, Duration correction}) {
    this.start = reporting;
    this.end = onBlocks;
    this.addition = Duration.zero; // Particular...
    this.numberOfLandings = numberOfLandings;
    this.correction = correction;
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

  Duration get maxFlightDutyPeriodLength {
    return this._getMaxFlightDutyLength() - correction;
  }
  AwareDT get maxFlightDutyPeriodEndTime =>
      this.start
          .add(this.maxFlightDutyPeriodLength)
          .subtract(this.start.timeZoneDifference(this.end));
  Period get maxFlightDutyPeriod =>
      Period(from: this.start, to: maxFlightDutyPeriodEndTime);

  Duration get extendedFlightDutyPeriodLength =>
      this.maxFlightDutyPeriodLength + Duration(hours: 2);
  AwareDT get extendedFlightDutyPeriodEndTime =>
      this.start
          .add(this.extendedFlightDutyPeriodLength)
          .subtract(this.start.timeZoneDifference(this.end));
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

  Rest(AwareDT dutyStart, AwareDT dutyEnd, {Duration addition = Duration.zero}) {
    start = dutyEnd;
    end = start.add(_getMinimumRestDuration(
        dutyEnd.difference(dutyStart) + addition));
  }

  Rest.fromDuty(Duty duty) {

    // Rest immediately follows the end of the last duty.
    this.start = duty.endTime;

    if (!duty.involveRest) {
      this.end = duty.endTime;
      return;
    }

    this.end = this.start.add(this._getMinimumRestDuration(duty.duration));
  }

  Rest.fromFTLInputs(AwareDT reporting, AwareDT onBlocks) {
    this.start = onBlocks.add(Duration(minutes: 30));
    Duration fdpDuration = onBlocks.utc.difference(reporting.utc) + Duration(minutes: 30);
    this.end = this.start.add(_getMinimumRestDuration(fdpDuration));
  }

  String toString() {
    return '|REST|from: ' + this.start.toString() +
            '|to: ' + this.end.toString() + '|duration: ' + this.durationString;
  }

  Duration _getMinimumRestDuration(Duration fdpDuration) {
    /// Minimum Rest equals to preceding duty period or 11 hours whichever is
    /// longer.
    if (fdpDuration > Duration(hours: 11)) return fdpDuration;
    return Duration(hours: 11);
  }
}

class DutyPeriod extends Period {

  DutyPeriod({AwareDT start, AwareDT end, Duration addition}) {
    this.start = start;
    this.end = end;
    this.addition = addition;
  }

  DutyPeriod.fromDuty(Duty duty) {
    this.start = duty.startTime;
    this.end = duty.endTime;
  }

  DutyPeriod.fromAwareDT(AwareDT from, AwareDT to, {Duration addition}) {
    this.start = from;
    this.end = to;
    this.addition = addition;
  }

  String toString() {
    return '|DP|start: ' + this.start.toString() +
        '|end: ' + this.end.toString() +
        '|duration: ' + this.durationString;
  }
}
