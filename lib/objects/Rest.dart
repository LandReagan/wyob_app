import 'package:wyob/objects/Duty.dart' show Duty;
import 'package:wyob/utils/DateTimeUtils.dart' show AwareDT;


class Rest {

  AwareDT startTime;
  AwareDT endTime;

  Rest.fromDuty(Duty duty) {

    // Start time is duty end time (30 minutes after blocks on time)
    startTime = AwareDT.fromDateTimes(duty.endTime.loc, duty.endTime.utc);

    // Rest time is either 11 hours or total duty time whichever is longer.
    Duration dutyDuration = duty.endTime.utc.difference(duty.startTime.utc);
    Duration stdRestDuration = Duration(hours: 11);
      //duty.endPlace.IATA == 'MCT' ? Duration(hours: 11) : Duration(hours: 10);
    Duration restDuration =
      dutyDuration > stdRestDuration ? dutyDuration : stdRestDuration;

    endTime = AwareDT.fromDateTimes(
        startTime.loc.add(restDuration),
        startTime.utc.add(restDuration));
  }

  Duration get duration => endTime.utc.difference(startTime.utc);
}
