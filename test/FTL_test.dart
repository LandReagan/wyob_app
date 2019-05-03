import 'dart:math';

import 'package:test/test.dart';
import 'package:wyob/objects/FTL.dart' show FTL;
import 'package:wyob/objects/FTL.dart';
import 'package:wyob/utils/DateTimeUtils.dart';

void main() {
  group('Allowable Flight Duty Period', () {
    test('Table tests', () {
      var ftl = FTL();

      ftl.reporting = AwareDT.fromString('01Jan2000 08:00 +04:00');
      ftl.numberOfLandings = 2;
      expect(ftl.maxFlightDutyLength, Duration(hours: 14));
      ftl.numberOfLandings = 3;
      expect(ftl.maxFlightDutyLength, Duration(hours: 13, minutes: 15));
      ftl.numberOfLandings = 8;
      expect(ftl.maxFlightDutyLength, Duration(hours: 9, minutes: 30));

      ftl.reporting = AwareDT.fromString('01Jan2000 18:00 +04:00');
      ftl.numberOfLandings = 1;
      expect(ftl.maxFlightDutyLength, Duration(hours: 12, minutes: 00));
      ftl.numberOfLandings = 7;
      expect(ftl.maxFlightDutyLength, Duration(hours: 9, minutes: 00));
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
      period.start = DateTime.now();
      period.end = period.start.add(Duration(hours: 2));
      expect(period.duration, Duration(hours: 2));
    });

    test("'durationString' getter", () {
      Period period = Period(from: DateTime(1970, 1, 1), to: DateTime(1970, 1, 2, 12));
      expect(period.durationString, '36:00');
      period = Period(from: DateTime(1970, 1, 1), to: DateTime(1970, 1, 1, 0, 1));
      expect(period.durationString, '00:01');
    });
  });
}
