import 'dart:async';
import 'dart:convert';

import 'package:wyob/data/FileManager.dart';
import 'package:wyob/objects/Duty.dart';
import 'package:wyob/objects/DutyData.dart';
import 'package:wyob/utils/DateTimeUtils.dart';


class Database {

  /// Would return the list of duties, or an empty list in case of any
  /// problem (offline, data fetching failed, etc.)
  static Future<DutyData> getDuties() async {

    print("Reading duties from database...");

    List<Duty> duties = [];
    AwareDT lastUpdateTime;
    String dutiesJSON = await FileManager.readDutiesFile();

    // Get the JSON file as a Map
    if (dutiesJSON != "") {
      // TODO: error handling
      Map<String, dynamic> dutyObjects = json.decode(dutiesJSON);

      if (dutyObjects.containsKey('last_update')) {
        lastUpdateTime = AwareDT.fromString(dutyObjects['last_update']);
      }

      dutyObjects.remove('last_update');

      dutyObjects.forEach((index, dutyObject) {
        duties.add(new Duty.fromMap(dutyObject));
      });
    }

    print("Reading duties from database DONE!");

    return DutyData(lastUpdateTime, duties);
  }

  /// Would return the same as getDuties static method but without flights
  /// more than 3 days old.
  static Future<DutyData> getDutiesReduced() async {

    DutyData dutyData = await getDuties();
    List<Duty> allDuties = dutyData.duties;
    AwareDT lastUpdate = dutyData.lastUpdate;

    allDuties.removeWhere((duty) {
      return DateTime.now().difference(duty.endTime.loc).inDays > 4;
    });

    return DutyData(lastUpdate, allDuties);
  }


  /// Would get the database duties, update them with the 'new' duties,
  /// then write the new file and return the new list of duties (convenience)
  static Future<List<Duty>> updateDuties(
      AwareDT lastUpdate,
      List<Duty> newDuties,
    ) async {

    print("Updating duties in Database...");

    List<Duty> duties = (await getDuties()).duties;

    // We compare each new duty against all old duties, to clear old duties.
    newDuties.forEach((newDuty) {
      duties.removeWhere((duty) {
        /* If new duty timings (start and end) are together after or before,
           we do nothing. If not, we delete the old duty.
         */
        return !(newDuty.startTime.utc.isAfter(duty.rest.endTime.utc) ||
          newDuty.endTime.utc.isBefore(duty.startTime.utc));
      });
    });

    duties.addAll(newDuties);

    duties.sort((duty1, duty2) {
      return duty1.startTime.utc.compareTo(duty2.startTime.utc);
    });

    var dutiesJSON = Map<String, dynamic>();
    dutiesJSON['last_update'] = lastUpdate.toString();
    for (var i = 0; i < duties.length; i++) {
      dutiesJSON[i.toString()] = duties[i].toMap();
    }
    FileManager.writeCurrentDuties(json.encode(dutiesJSON));

    print("Updating duties in Database DONE!");

    return duties;
  }
}
