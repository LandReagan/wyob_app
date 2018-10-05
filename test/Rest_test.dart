import 'package:test/test.dart';

import 'package:wyob/utils/DateTimeUtils.dart';
import 'package:wyob/objects/Duty.dart';
import 'package:wyob/objects/Airport.dart';
import 'package:wyob/objects/Rest.dart';


void main() {

  test('Rest class tests:', () {

    Duty duty1 = Duty();
    duty1.nature = 'FLIGHT';
    duty1.startPlace = Airport.fromIata('MCT');
    duty1.endPlace = Airport.fromIata('DOH');
    duty1.startTime = AwareDT.fromDateTimes(
        DateTime(1978, 11, 15, 06, 20), DateTime(1978, 11, 15, 02, 20));
    duty1.endTime = AwareDT.fromDateTimes(
        DateTime(1978, 11, 15, 8, 35),DateTime(1978, 11, 15, 4, 35));

    Rest rest1 = Rest.fromDuty(duty1);

    expect(rest1.duration == Duration(hours: 10), true);

    AwareDT restStartTime = AwareDT.fromDateTimes(
        DateTime(1978, 11, 15, 9, 05), DateTime(1978, 11, 15, 5, 05));
    expect(rest1.startTime.utc == restStartTime.utc, true);

  });
}