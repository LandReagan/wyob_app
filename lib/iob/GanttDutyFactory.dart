import 'package:intl/intl.dart' show DateFormat;
import 'package:wyob/objects/Duty.dart';
import 'package:wyob/objects/Flight.dart';
import 'package:wyob/utils/DateTimeUtils.dart';

class GanttDutyFactory {

  static List<Duty> run(
      List<Map<String, dynamic>> dataLocal,
      List<Map<String, dynamic>> dataUtc)
  {
    List<Duty> duties = [];

    if (dataLocal.length != dataUtc.length) {
      throw Exception('Mismatch between Local and Utc data!');
    }

    for (int i = 0; i < dataLocal.length; i++) {
      Duty duty = Duty();

      if (dataLocal[i]['flights'].length > 0) duty.nature = 'FLIGHT';

      duty.startTime = AwareDT.fromIobString(
          dataLocal[i]['date'] + ' ' + dataLocal[i]['start_time'] +
          ' (' + dataUtc[i]['start_time'] + ')');

      duty.endTime = AwareDT.fromIobString(
          dataLocal[i]['date'] + ' ' + dataLocal[i]['end_time'] +
              ' (' + dataUtc[i]['end_time'] + ')');

      for (int j = 0; j < dataLocal[i]['flights'].length; j++) {
        String flightNumber = dataLocal[i]['flights'][j]['flight_number'];
        String localFlightDate = dataLocal[i]['flights'][j]['date'];
        String localFlightStartTime = dataLocal[i]['flights'][j]['start'];
        String utcFlightStartTime = dataUtc[i]['flights'][j]['start'];
        String localFlightEndTime = dataLocal[i]['flights'][j]['end'];
        String utcFlightEndTime = dataUtc[i]['flights'][j]['end'];
        String localFlightFrom = dataUtc[i]['flights'][j]['from'];
        String localFlightTo = dataUtc[i]['flights'][j]['to'];

        String flightStartIob = localFlightDate + ' ' +
            localFlightStartTime + ' (' + utcFlightStartTime + ')';
        String flightEndIob = localFlightDate + ' ' +
            localFlightEndTime + ' (' + utcFlightEndTime + ')';

        Map<String, String> iobMap = {
          'Start' : flightStartIob,
          'End' : flightEndIob,
          'From': localFlightFrom,
          'To': localFlightTo,
          'Flight': flightNumber
        };

        duty.addFlight(Flight.fromIobMap(iobMap));
      }

      //print(duty);

      duties.add(duty);
    }

    return duties;
  }
}
