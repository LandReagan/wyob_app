import 'dart:io' show File;
import 'package:flutter_test/flutter_test.dart';
import 'package:wyob/iob/GanttDutyFactory.dart' show GanttDutyFactory;
import 'package:wyob/objects/Duty.dart';
import 'package:wyob/objects/Flight.dart';
import 'package:wyob/utils/Parsers.dart' show parseGanttDuty;

void main() {

  group("Duty example 1", () {
    List<Map<String, dynamic>> dummyDutiesLocal = [];
    List<Map<String, dynamic>> dummyDutiesUtc = [];
    File file1Local = File('test/HTML files/duty_gantt_example_Local.html');
    File file1Utc = File('test/HTML files/duty_gantt_example_Utc.html');
    String file1LocalText = file1Local.readAsStringSync();
    String file1UtcText = file1Utc.readAsStringSync();
    List<Map<String, dynamic>> file1LocalData = parseGanttDuty(file1LocalText);
    List<Map<String, dynamic>> file1UtcData = parseGanttDuty(file1UtcText);

    test('shall return a list of duties', () {
      expect(GanttDutyFactory.run(dummyDutiesLocal, dummyDutiesUtc).runtimeType.toString() == 'List<Duty>', true);
    });

    test('example1 should return 2 duties', () {
      expect(GanttDutyFactory.run(file1LocalData, file1UtcData).length, 2);
    });

    test('example1 duties times should be correct', () {
      expect(
          GanttDutyFactory.run(file1LocalData, file1UtcData)[0].startTime.toString(),
          '05Apr2019 00:30 +04:00');
      expect(
          GanttDutyFactory.run(file1LocalData, file1UtcData)[1].startTime.toString(),
          '06Apr2019 09:25 +02:00');
    });

    test('example1 duty1 should have nature "FLIGHT"', () {
      expect(GanttDutyFactory.run(file1LocalData, file1UtcData)[0].nature, 'FLIGHT');
    });

    test('example1 duty2 flight should be correct', () {
      Flight flight = GanttDutyFactory.run(file1LocalData, file1UtcData)[1].flights[0];
      expect(flight.flightNumber, 'WY142');
      expect(flight.startPlace.IATA, 'MXP');
      expect(flight.endPlace.IATA, 'MCT');
    });
  });

  group("Duty example 2", () {
    File file2Local = File('test/HTML files/duty_gantt_example2_Local.html');
    File file2Utc = File('test/HTML files/duty_gantt_example2_Utc.html');
    String file2LocalText = file2Local.readAsStringSync();
    String file2UtcText = file2Utc.readAsStringSync();
    List<Map<String, dynamic>> file2LocalData = parseGanttDuty(file2LocalText);
    List<Map<String, dynamic>> file2UtcData = parseGanttDuty(file2UtcText);
    List<Duty> duties = GanttDutyFactory.run(file2LocalData, file2UtcData);

    test('example2 should return 2 duties', () {
      expect(duties.length, 2);
    });

    test('example 2 should get correct duties', () {
      expect(duties[1].duration.inMinutes, 535);
      expect(duties[0].flights[0].flightNumber, 'WY821');
      expect(duties[0].flights[0].endPlace.IATA, 'KUL');
      expect(duties[0].flights[0].endTime.toString(), '10Apr2019 07:45 +08:00');
      expect(duties[0].flights[0].duration.inMinutes, 395);
    });
  });

  group("Duty example HS-PM", () {
    File fileLocal = File('test/HTML files/duty_gantt_example_HSPM_Local.html');
    File fileUtc = File('test/HTML files/duty_gantt_example_HSPM_Utc.html');
    String fileLocalText = fileLocal.readAsStringSync();
    String fileUtcText = fileUtc.readAsStringSync();
    List<Map<String, dynamic>> fileLocalData = parseGanttDuty(fileLocalText);
    List<Map<String, dynamic>> fileUtcData = parseGanttDuty(fileUtcText);
    List<Duty> duties = GanttDutyFactory.run(fileLocalData, fileUtcData);

    test('HS-PM example should return 1 duty', () {
      expect(duties.length, 1);
    });

    test('HS-PM example should return a duty nature STDBY', () {
      print(duties[0]);
      expect(duties[0].nature, 'STDBY');
    });
  });

  group("Duty example NOPS", () {

    File fileLocal = File('test/HTML files/duty_gantt_example_NOPS_Local.html');
    File fileUtc = File('test/HTML files/duty_gantt_example_NOPS_Utc.html');
    String fileLocalText = fileLocal.readAsStringSync();
    String fileUtcText = fileUtc.readAsStringSync();
    List<Map<String, dynamic>> fileLocalData = parseGanttDuty(fileLocalText);
    List<Map<String, dynamic>> fileUtcData = parseGanttDuty(fileUtcText);
    List<Duty> duties = GanttDutyFactory.run(fileLocalData, fileUtcData);

    test("Should return a correct NOPS duty", () {
      expect(duties.length, 1);
      expect(duties[0].nature, 'NOPS');
      expect(duties[0].code, 'NOPS');
      expect(duties[0].startTime.toString(), '04Apr2019 00:00 +04:00');
      expect(duties[0].endTime.toString(), '04Apr2019 23:59 +04:00');
      expect(duties[0].duration.inMinutes, 1439);
    });
  });

  group("Duty example NOPS", ()
  {
    File fileLocal = File('test/HTML files/20190429 MCT MUC MCT.html');
    File fileUtc = File('test/HTML files/20190429 MCT MUC MCT Utc.html');
    String fileLocalText = fileLocal.readAsStringSync();
    String fileUtcText = fileUtc.readAsStringSync();
    List<Map<String, dynamic>> fileLocalData = parseGanttDuty(fileLocalText);
    List<Map<String, dynamic>> fileUtcData = parseGanttDuty(fileUtcText);
    List<Duty> duties = GanttDutyFactory.run(fileLocalData, fileUtcData);

    test("should build 2 duties", () {
      duties.forEach((duty) => print(duty));
      expect(duties.length, 2);
    });
  });

  group("TRI's duties", () {
    String folderPath = "test/HTML files/jp/";

    test("Activity 1", () {
      String contentLoc = File(folderPath + "jpg_gantt_activity_1_loc.html")
          .readAsStringSync();
      List<Map<String, dynamic>> rawDutyLoc = parseGanttDuty(contentLoc);
      String contentUtc = File(folderPath + "jpg_gantt_activity_1_utc.html")
          .readAsStringSync();
      List<Map<String, dynamic>> rawDutyUtc = parseGanttDuty(contentUtc);
      print(GanttDutyFactory.run(rawDutyLoc, rawDutyUtc));
    });

    test("Activity 2", () {
      String contentLoc = File(folderPath + "jpg_gantt_activity_2_loc.html")
          .readAsStringSync();
      List<Map<String, dynamic>> rawDutyLoc = parseGanttDuty(contentLoc);
      String contentUtc = File(folderPath + "jpg_gantt_activity_2_utc.html")
          .readAsStringSync();
      List<Map<String, dynamic>> rawDutyUtc = parseGanttDuty(contentUtc);
      print(GanttDutyFactory.run(rawDutyLoc, rawDutyUtc));
    });

    test("Activity 3", () {
      String contentLoc = File(folderPath + "jpg_gantt_activity_3_loc.html")
          .readAsStringSync();
      List<Map<String, dynamic>> rawDutyLoc = parseGanttDuty(contentLoc);
      String contentUtc = File(folderPath + "jpg_gantt_activity_3_utc.html")
          .readAsStringSync();
      List<Map<String, dynamic>> rawDutyUtc = parseGanttDuty(contentUtc);
      print(GanttDutyFactory.run(rawDutyLoc, rawDutyUtc));
    });

    test("Activity 4", () {
      String contentLoc = File(folderPath + "jpg_gantt_activity_4_loc.html")
          .readAsStringSync();
      List<Map<String, dynamic>> rawDutyLoc = parseGanttDuty(contentLoc);
      String contentUtc = File(folderPath + "jpg_gantt_activity_4_utc.html")
          .readAsStringSync();
      List<Map<String, dynamic>> rawDutyUtc = parseGanttDuty(contentUtc);
      print(GanttDutyFactory.run(rawDutyLoc, rawDutyUtc));
    });

    test("Activity 5", () {
      String contentLoc = File(folderPath + "jpg_gantt_activity_5_loc.html")
          .readAsStringSync();
      List<Map<String, dynamic>> rawDutyLoc = parseGanttDuty(contentLoc);
      String contentUtc = File(folderPath + "jpg_gantt_activity_5_utc.html")
          .readAsStringSync();
      List<Map<String, dynamic>> rawDutyUtc = parseGanttDuty(contentUtc);
      print(GanttDutyFactory.run(rawDutyLoc, rawDutyUtc));
    });
  });
}
