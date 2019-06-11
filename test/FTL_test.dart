import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'package:wyob/objects/FTL.dart';
import 'package:wyob/objects/Duty.dart';
import 'package:wyob/objects/Airport.dart';
import 'package:wyob/utils/DateTimeUtils.dart';
import 'package:wyob/widgets/StandbyTypeWidget.dart';

void main() {
  group('Allowable Flight Duty Period', () {
    test('Table tests', () {
      var fdp = FlightDutyPeriod();

      fdp.reporting = AwareDT.fromString('01Jan2000 08:00 +04:00');
      fdp.numberOfLandings = 2;
      expect(fdp.maxFlightDutyPeriodLength, Duration(hours: 14));
      fdp.numberOfLandings = 3;
      expect(fdp.maxFlightDutyPeriodLength, Duration(hours: 13, minutes: 15));
      fdp.numberOfLandings = 8;
      expect(fdp.maxFlightDutyPeriodLength, Duration(hours: 9, minutes: 30));

      fdp.reporting = AwareDT.fromString('01Jan2000 18:00 +04:00');
      fdp.numberOfLandings = 1;
      expect(fdp.maxFlightDutyPeriodLength, Duration(hours: 12, minutes: 00));
      fdp.numberOfLandings = 7;
      expect(fdp.maxFlightDutyPeriodLength, Duration(hours: 9, minutes: 00));
    });
  });

  group("Period class tests", () {

    test('null Period', () {
      Period period = Period();
      expect(period.duration, null);
      expect(period.durationString, null);
    });

    test("'duration' getter", () {
      Period period = Period();
      period.start = AwareDT.now();
      period.end = period.start.add(Duration(hours: 2));
      expect(period.duration, Duration(hours: 2));
    });

    test("'durationString' getter", () {
      Period period = Period(
        from: AwareDT.fromDateTimes(DateTime(1970, 1, 1), DateTime(1970, 1, 1, 2)),
          to: AwareDT.fromDateTimes(DateTime(1970, 1, 2, 12), DateTime(1970, 1, 2, 14))
      );
      expect(period.durationString, '36h00m');
      period = period = Period(
          from: AwareDT.fromDateTimes(DateTime(1970, 1, 1, 0, 0), DateTime(1970, 1, 1, 2, 0)),
          to: AwareDT.fromDateTimes(DateTime(1970, 1, 1, 0, 1), DateTime(1970, 1, 1, 2, 1))
      );
      expect(period.durationString, '00h01m');
    });
  });

  test('Rest class tests:', () {

    Duty duty1 = Duty();
    duty1.nature = DUTY_NATURE.FLIGHT;
    duty1.startPlace = Airport.fromIata('MCT');
    duty1.endPlace = Airport.fromIata('DOH');
    duty1.startTime = AwareDT.fromDateTimes(
        DateTime(1978, 11, 15, 06, 20), DateTime(1978, 11, 15, 02, 20));
    duty1.endTime = AwareDT.fromDateTimes(
        DateTime(1978, 11, 15, 8, 35),DateTime(1978, 11, 15, 4, 35));

    Rest rest1 = Rest.fromDuty(duty1);
    expect(rest1.duration == Duration(hours: 11), true);

    AwareDT restStartTime = AwareDT.fromDateTimes(
        DateTime(1978, 11, 15, 9, 05), DateTime(1978, 11, 15, 4, 35));
    expect(rest1.start.utc == restStartTime.utc, true);
  });

  group('Tests of the duty collection', () {

    Map<String, dynamic> data = json.decode(File('test/duties_as_json.json').readAsStringSync());

    List<Duty> duties = [];

    int i = 0;
    while(data[i.toString()] != null) {
      duties.add(Duty.fromMap(data[i.toString()]));
      i++;
    }

    for (Duty duty in duties) {
      //print(duty.toString());
      //print(duty.ftl.toString());
    }
  });

  group('Tests of flight duty with previous stand by', () {
    test('Home STDBY from 02:00, flight reporting at 08:00, blocks at 12:00', () {
      FTL ftl = FTL.fromWidget(
          reportingDate: DateTime(1970, 1, 1),
          reportingTime: TimeOfDay(hour: 8, minute: 0),
          numberOfLandings: 2,
          reportingGMTDiff: Duration(hours: 4),
          onBlocks: TimeOfDay(hour: 12, minute: 0),
          onBlocksGMTDiff: Duration(hours: 4),
          isStandby: true,
          standbyStartTime: TimeOfDay(hour: 2, minute: 0),
          standbyType: STANDBY_TYPE.HOME
      );

      print(ftl.flightDutyPeriod);
      print(ftl.dutyPeriod);

    });
  });
}
