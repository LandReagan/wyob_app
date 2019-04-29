import 'dart:math';

import 'package:test/test.dart';
import 'package:wyob/objects/FTL.dart' show FTL;
import 'package:wyob/utils/DateTimeUtils.dart';

void main() {
  group('Allowable Flight Duty Period', () {
    test('Table tests', () {
      var ftl = FTL();

      ftl.reporting = AwareDT.fromString('01Jan2000 08:00 +04:00');
      ftl.numberOfLandings = 2;
      expect(ftl.maxFlightDutyPeriod, Duration(hours: 14));
      ftl.numberOfLandings = 3;
      expect(ftl.maxFlightDutyPeriod, Duration(hours: 13, minutes: 15));
      ftl.numberOfLandings = 8;
      expect(ftl.maxFlightDutyPeriod, Duration(hours: 9, minutes: 30));

      ftl.reporting = AwareDT.fromString('01Jan2000 18:00 +04:00');
      ftl.numberOfLandings = 1;
      expect(ftl.maxFlightDutyPeriod, Duration(hours: 12, minutes: 00));
      ftl.numberOfLandings = 7;
      expect(ftl.maxFlightDutyPeriod, Duration(hours: 9, minutes: 00));
    });
  });
}
