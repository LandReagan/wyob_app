import 'dart:io' show File;
import 'dart:convert';

import 'package:test/test.dart';

import 'package:wyob/IobConnect.dart' show IobConnect;
import 'package:wyob/IobDutyFactory.dart' show IobDutyFactory;
import 'package:wyob/Duty.dart';


File checkinAsTextFile = new File("./test/checkin_list_as_txt.txt");
File dutiesAsJsonFile = new File("./test/duties_as_json.json");


void main() {

  test("Get current own duties with no errors", () async {

    // 1. Get checkin list as text
    String checkinListAsText = await IobConnect.run('93429', '93429');
    checkinAsTextFile.writeAsStringSync(checkinListAsText);

    // 2. Get duties list out of the text
    List<Duty> duties = IobDutyFactory.run(checkinListAsText);

    // 3. Write duties as json
    var jsonDuties = new Map<String, dynamic>();
    for (var i = 0; i < duties.length; i++) {
      jsonDuties[i.toString()] = duties[i].toMap();
    }
    dutiesAsJsonFile.writeAsStringSync(json.encode(jsonDuties));

    for (Duty duty in duties) {
      expect(duty.nature, isNotNull);
    }
  });

  test("Build duties from json file", () {
    String jsonDuties = dutiesAsJsonFile.readAsStringSync();
    Map<String, dynamic> dutyObjects = json.decode(jsonDuties);
    List<Duty> duties = [];
    dutyObjects.forEach((index, dutyObject) {
      duties.add(new Duty.fromMap(dutyObject));
    });
    duties.forEach((duty) => print('$duty'));
  });
}