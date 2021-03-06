import 'package:intl/intl.dart';
import 'package:wyob/objects/Airport.dart';
import 'package:wyob/objects/Duty.dart';
import 'package:wyob/objects/Flight.dart';
import 'package:wyob/utils/DateTimeUtils.dart';
import 'package:wyob/iob/IobCodes.dart' show IOB_CODES;

class GanttDutyFactory {

  /// Converts a list of Map containing duty data into a list of Duty objects.
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

      if (dataLocal[i]['flights'] != null) {
        dataLocal[i]['end_time'] = dataLocal[i]['end_time'].substring(0, 5);
        dataUtc[i]['end_time'] = dataUtc[i]['end_time'].substring(0, 5);

        DateTime locStart = DateFormat('dMMMy H:m').parse(
            dataLocal[i]['date'] + ' ' + dataLocal[i]['start_time']);
        DateTime utcStart = DateFormat('dMMMy H:m').parse(
            dataUtc[i]['date'] + ' ' + dataUtc[i]['start_time']);
        DateTime locEnd = DateFormat('dMMMy H:m').parse(
            dataLocal[i]['date'] + ' ' + dataLocal[i]['end_time']);
        DateTime utcEnd = DateFormat('dMMMy H:m').parse(
            dataUtc[i]['date'] + ' ' + dataUtc[i]['end_time']);

        if (locEnd.isBefore(locStart)) locEnd = locEnd.add(Duration(hours: 24));
        if (utcEnd.isBefore(utcStart)) utcEnd = utcEnd.add(Duration(hours: 24));

        if (dataLocal[i]['flights'].length > 0) duty.nature = 'FLIGHT';

        duty.startTime = AwareDT.fromDateTimes(locStart, utcStart);
        duty.endTime = AwareDT.fromDateTimes(locEnd, utcEnd);

        for (int j = 0; j < dataLocal[i]['flights'].length; j++) {
          String flightNumber = dataLocal[i]['flights'][j]['flight_number'];
          String localFlightFrom = dataUtc[i]['flights'][j]['from'];
          String localFlightTo = dataUtc[i]['flights'][j]['to'];

          DateTime locFlightStartTime = DateFormat('dMMMy H:m').parse(
              dataLocal[i]['flights'][j]['date'] + ' '
                  + dataLocal[i]['flights'][j]['start']);
          DateTime utcFlightStartTime = DateFormat('dMMMy H:m').parse(
              dataUtc[i]['flights'][j]['date'] + ' '
                  + dataUtc[i]['flights'][j]['start']);
          DateTime locFlightEndTime = DateFormat('dMMMy H:m').parse(
              dataLocal[i]['flights'][j]['date'] + ' '
                  + dataLocal[i]['flights'][j]['end']);
          DateTime utcFlightEndTime = DateFormat('dMMMy H:m').parse(
              dataUtc[i]['flights'][j]['date'] + ' '
                  + dataUtc[i]['flights'][j]['end']);

          if (locFlightEndTime.isBefore(locFlightStartTime))
            locFlightEndTime = locFlightEndTime.add(Duration(hours: 24));
          if (utcFlightEndTime.isBefore(utcFlightStartTime))
            utcFlightEndTime = utcFlightEndTime.add(Duration(hours: 24));

          AwareDT startTime = AwareDT.fromDateTimes(
              locFlightStartTime, utcFlightStartTime);
          AwareDT endTime = AwareDT.fromDateTimes(
              locFlightEndTime, utcFlightEndTime);

          Map<String, dynamic> iobMap = {
            'startTime': startTime.toString(),
            'endTime': endTime.toString(),
            'startPlace': localFlightFrom,
            'endPlace': localFlightTo,
            'flightNumber': flightNumber
          };
          duty.addFlight(Flight.fromMap(iobMap));
        }
      } else { // Stand by's, OFF, NOPS, etc...

        String dutyCode = dataLocal[i]['type'];
        duty.code = dutyCode;
        if (IOB_CODES.containsKey(dutyCode)) {
          duty.nature = IOB_CODES[dutyCode];
        }

        DateTime startTimeLocal = DateFormat('dMMMy H:m').parse(dataLocal[i]['start']);
        DateTime startTimeUtc = DateFormat('dMMMy H:m').parse(dataUtc[i]['start']);
        DateTime endTimeLocal = DateFormat('dMMMy H:m').parse(dataLocal[i]['end']);
        DateTime endTimeUtc = DateFormat('dMMMy H:m').parse(dataUtc[i]['end']);

        AwareDT startTime = AwareDT.fromDateTimes(startTimeLocal, startTimeUtc);
        AwareDT endTime = AwareDT.fromDateTimes(endTimeLocal, endTimeUtc);

        duty.startTime = startTime;
        duty.endTime = endTime;

        duty.startPlace = Airport.fromIata(dataLocal[i]['from']);
        duty.endPlace = Airport.fromIata(dataLocal[i]['to']);
      }

      DateTime utcNow = DateTime.now().toUtc();
      if (duty.startTime.utc.isAfter(utcNow)) {
        duty.status = DUTY_STATUS.PLANNED;
      } else if (duty.endTime.utc.isBefore(utcNow)) {
        duty.status = DUTY_STATUS.DONE;
      } else {
        duty.status = DUTY_STATUS.ON_GOING;
      }

      duties.add(duty);
    }
    return duties;
  }
}
