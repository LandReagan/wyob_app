import 'dart:io' show File;
import 'dart:convert';

@Timeout(const Duration(seconds: 45))

import 'package:test/test.dart';
import 'package:wyob/data/LocalDatabase.dart';
import 'package:wyob/iob/GanttDutyFactory.dart';

import 'package:wyob/iob/IobConnector.dart' show IobConnector;
import 'package:wyob/iob/IobDutyFactory.dart' show IobDutyFactory;
import 'package:wyob/objects/Duty.dart';
import 'package:wyob/utils/Parsers.dart';


File checkinAsTextFile = new File("./test/checkin_list_as_txt.txt");
File dutiesAsJsonFile = new File("./test/duties_as_json.json");


void main() {

  test("Get current own duties with no errors", () async {

    // 1. Get checkin list as text
    IobConnector connector = IobConnector();
    connector.setCredentials("93429", "93429iob!");
    String checkinListAsText = await connector.init();
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

  test('Gantt stuff', () async {

    IobConnector connector = IobConnector();
    connector.setCredentials("93429", "93429iob!");

    // Get the references...
    String referencesString = await connector.getFromToGanttDuties(
        DateTime.now().subtract(Duration(days: 100)),
        DateTime.now().subtract(Duration(days: 69))
    );

    List<Map<String, dynamic>> references = parseGanttMainTable(referencesString);

    List<Duty> duties = [];
    for (var reference in references) {
      String rotationStringLocal =
        reference['type'] == 'Trip' ?
          await connector.getGanttDutyTripLocal(1, 1, reference['personId'], reference['persAllocId']) :
          await connector.getGanttDutyAcyLocal(1, 1, reference['personId'], reference['persAllocId']);

      String rotationStringUtc =
        reference['type'] == 'Trip' ?
          await connector.getGanttDutyTripUtc(reference['personId'], reference['persAllocId']) :
          await connector.getGanttDutyAcyUtc(reference['personId'], reference['persAllocId']);

      List<Map<String, dynamic>> rotationDutiesDataLocal = parseGanttDuty(rotationStringLocal);
      List<Map<String, dynamic>> rotationDutiesDataUtc = parseGanttDuty(rotationStringUtc);

      List<Duty> rotationDuties = GanttDutyFactory.run(rotationDutiesDataLocal, rotationDutiesDataUtc);
      duties.addAll(rotationDuties);
    }
    duties.forEach((duty) => print(duty));
  });

  test('Get the duties from nothing (first connection)', () async {
    LocalDatabase database = LocalDatabase();
    await database.connect();
    var duties = database.getDuties(
        DateTime.now(), DateTime.now().add(Duration(days: 5)));
    expect(duties.length, 0);
  });

  test('Statistics of my September 2019 duties', () async {
    IobConnector connector = IobConnector();
    connector.setCredentials('93429', '93429iob!');
    String txt = await connector.getFromToGanttDuties(
        DateTime(2019, 09, 01), DateTime(2019, 09, 20));
    var dataList = parseGanttMainTable(txt);
    var rawDutyLocList = <Map<String, dynamic>>[];
    var rawDutyUtcList = <Map<String, dynamic>>[];
    for (var data in dataList) {
      var personId = data['personId'];
      var persAllocId = data['persAllocId'];
      String rawDutyDataLoc;
      String rawDutyDataUtc;
      if (data['type'] == 'Trip') {
        rawDutyDataLoc = await connector.getGanttDutyTripLocal(0, 0, personId, persAllocId);
        rawDutyDataUtc = await connector.getGanttDutyTripUtc(personId, persAllocId);
      } else {
        rawDutyDataLoc = await connector.getGanttDutyAcyLocal(0, 0, personId, persAllocId);
        rawDutyDataUtc = await connector.getGanttDutyAcyUtc(personId, persAllocId);
      }
      rawDutyLocList.addAll(parseGanttDuty(rawDutyDataLoc));
      rawDutyUtcList.addAll(parseGanttDuty(rawDutyDataUtc));
    }
    var duties = GanttDutyFactory.run(rawDutyLocList, rawDutyUtcList);
    for (var duty in duties) print(duty);
    var statistics = LocalDatabase().buildStatistics(dutyList: duties);
    for (var statistic in statistics) print(statistic);
  });

}
