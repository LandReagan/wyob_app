import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wyob/utils/DateTimeUtils.dart';
import 'package:wyob/objects/Duty.dart';

/// Used to calculate all FTLs. It is constructed thanks to a Duty and give
/// Rest and FlightDutyPeriod objects.
class FTL {

  // Optional
  final Duty _duty;

  // Mandatory
  AwareDT reporting;
  bool isFlightDuty;
  int numberOfLandings;
  AwareDT onBlocks;
  AwareDT offDuty;

  FTL(this._duty) : reporting = _duty?.startTime, isFlightDuty = _duty?.isFlight,
        onBlocks = _duty?.lastFlight?.endTime,
        numberOfLandings = _duty == null ? 0 : _duty.flights.length,
        offDuty = _duty?.endTime;

  FTL.fromWidget({
        @required DateTime reportingDate,
        @required TimeOfDay reportingTime,
        @required Duration reportingGMTDiff,
        @required int numberOfLandings,
        @required TimeOfDay onBlocks,
        @required Duration onBlocksGMTDiff
  }) : this._duty = null {
    DateTime reportingLoc = reportingDate;
    reportingLoc = reportingLoc.add(
        Duration(hours: reportingTime.hour, minutes: reportingTime.minute));
    DateTime reportingUtc = reportingLoc.subtract(reportingGMTDiff);
    this.reporting = AwareDT.fromDateTimes(reportingLoc, reportingUtc);

    if (numberOfLandings > 0) this.isFlightDuty = true;

    this.numberOfLandings = numberOfLandings;

    DateTime onBlocksLoc = reportingDate;
    onBlocksLoc = onBlocksLoc.add(
        Duration(hours: onBlocks?.hour, minutes: onBlocks.minute));
    DateTime onBlocksUtc = onBlocksLoc.subtract(onBlocksGMTDiff);
    this.onBlocks = AwareDT.fromDateTimes(onBlocksLoc, onBlocksUtc);
    if (this.reporting > this.onBlocks)
        this.onBlocks = this.onBlocks.add(Duration(hours: 24));
    this.offDuty = this.onBlocks.add(Duration(minutes: 30));
  }

  FlightDutyPeriod get flightDutyPeriod {

    // todo: case of stand by before flight duty
    if (!this.isFlightDuty || !this.isValid) return null;

    return FlightDutyPeriod(
      reporting: this.reporting,
      onBlocks: this.onBlocks,
      numberOfLandings: numberOfLandings
    );
  }

  Rest get rest {
    if (!this.isValid) return null;

    if (this._duty != null && this._duty.involveRest) return Rest.fromDuty(this._duty);

    return Rest.fromFTLInputs(reporting, onBlocks);
  }

  DutyPeriod get dutyPeriod {
    return DutyPeriod.fromAwareDT(this.reporting, this.offDuty);
  }

  bool get isValid {
    if (reporting > onBlocks) return false;
    if (isFlightDuty && (numberOfLandings < 1 || numberOfLandings > 8)) return false;
    return true;
  }

  String toString() {
    if (!this.isValid) return 'INVALID FTL OBJECT';
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

  String get durationString => durationToStringHM(duration);
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

  DutyPeriod.fromDuty(Duty duty) {
    this.start = duty.startTime;
    this.end = duty.endTime;
  }

  DutyPeriod.fromAwareDT(AwareDT from, AwareDT to) {
    this.start = from;
    this.end = to;
  }
}
