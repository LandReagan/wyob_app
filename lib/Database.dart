import 'dart:async';
import 'dart:convert';

import 'FileManager.dart';
import 'Duty.dart';


class Database {

  /// Would return the list of duties, or an empty list in case of any
  /// problem (offline, data fetching failed, etc.)
  static Future<List<Duty>> getDuties() async {

    List<Duty> duties = [];
    String dutiesJSON = await FileManager.readDutiesFile();

    if (dutiesJSON != "") {
      Map<String, dynamic> dutyObjects = json.decode(dutiesJSON);
      dutyObjects.forEach((index, dutyObject) {
        duties.add(new Duty.fromMap(dutyObject));
      });
    }
    return duties;
  }

  static Future<List<Duty>> updateDuties(List<Duty> newDuties) async {

    List<Duty> duties = await getDuties();

    // We compare each new duty against all old duties, to clear old duties.
    newDuties.forEach((newDuty) {
      duties.removeWhere((duty) {
        /* If new duty timings (start and end) are together after or before,
           we do nothing. If not, we delete the old duty.
         */
        return !(newDuty.startTime.utc.isAfter(duty.endTime.utc) ||
          newDuty.endTime.utc.isBefore(duty.startTime.utc));
      });
    });

    duties.addAll(newDuties);

    duties.sort((duty1, duty2) {
      return duty1.startTime.utc.compareTo(duty2.startTime.utc);
    });

    var dutiesJSON = Map<String, dynamic>();
    for (var i = 0; i < duties.length; i++) {
      dutiesJSON[i.toString()] = duties[i].toMap();
    }
    FileManager.writeCurrentDuties(json.encode(dutiesJSON));

    return duties;
  }
}
