import 'package:wyob/objects/Duty.dart' show Duty;
import 'package:wyob/utils/DateTimeUtils.dart' show AwareDT;


class Rest {

  AwareDT startTime;
  AwareDT endTime;

  Rest.fromDuty(Duty duty) {

    // Start time is 30 minutes after duty end time
    Duration restStart = Duration(minutes: 30);
    startTime = AwareDT.fromDateTimes(
      duty.endTime.loc.add(restStart),
      duty.endTime.utc.add(restStart)
    );

    // Rest time is either 11 hours at MCT or 10 hours outstation,
    // or total duty time whichever is longer.
    Duration dutyDuration = duty.endTime.utc.difference(duty.startTime.utc);
    Duration stdRestDuration =
      duty.endPlace.IATA == 'MCT' ? Duration(hours: 11) : Duration(hours: 10);
    Duration restDuration =
      dutyDuration > stdRestDuration ? dutyDuration : stdRestDuration;

    endTime = AwareDT.fromDateTimes(
        startTime.loc.add(restDuration),
        startTime.utc.add(restDuration));
  }

  Duration get duration => endTime.utc.difference(startTime.utc);
}