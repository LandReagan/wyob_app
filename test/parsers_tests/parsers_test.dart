
import 'package:test/test.dart';
import 'dart:io';
import 'dart:convert' show jsonEncode;

import 'package:wyob/utils/Parsers.dart';


void main() {

  test("GANTT main table parsing", () {
    File input = File("test/HTML files/gantt_example.html");
    String content = input.readAsStringSync();

    expect(parseGanttMainTable(content) is List<Map<String, String>>, true);

    List<Map<String, String>> result = parseGanttMainTable(content);

    expect(result.length, 20);

    expect(result[0]['personId'], '17729');
    expect(result[0]['persAllocId'], '14085584');

    expect(result[19]['personId'], '17729');
    expect(result[19]['persAllocId'], '14146885');
  });

  test("GANTT rotation page", () {
    File input = File("test/HTML files/duty_gantt_example_Local.html");
    String content = input.readAsStringSync();

    expect(parseGanttDuty(content) is List<Map<String, dynamic>>, true);

    List<Map<String, dynamic>> result = parseGanttDuty(content);

    expect(result.length, 2);
    expect(result[0].keys.contains("date"), true);
    expect(result[0]['date'], '05Apr2019');
    expect(result[0]['flights'].length, 1);
    expect(result[0]['flights'][0]['flight_number'], "WY141");
    expect(result[1]['flights'][0]['end'], "19:05");
  });

  test("GANTT rotation page", () {
    File input = File("test/HTML files/duty_gantt_example_Utc.html");
    String content = input.readAsStringSync();

    expect(parseGanttDuty(content) is List<Map<String, dynamic>>, true);

    List<Map<String, dynamic>> result = parseGanttDuty(content);

    expect(result.length, 2);
    expect(result[0].keys.contains("date"), true);
    expect(result[0]['date'], '04Apr2019');
    expect(result[0]['flights'].length, 1);
    expect(result[0]['flights'][0]['flight_number'], "WY141");
    expect(result[1]['flights'][0]['end'], "15:05");
  });

  group("should parse 20190229 MCT MUC MCT correctly", () {
    File input = File("test/HTML files/20190429 MCT MUC MCT.html");
    String content = input.readAsStringSync();
    List<Map<String, dynamic>> result = parseGanttDuty(content);

    test("should parse date", () {
      expect(result[0]['date'], '26Apr2019');
    });
  });

  group("TRI's duties tests", () {
    String folderPath = "test/HTML files/jp/";

    test("GANTT Table", () {
      String content = File(folderPath + "jpg_gantt_table.html")
          .readAsStringSync();
      List<Map<String, dynamic>> result = parseGanttMainTable(content);
      expect(result.length, 29);
    });

    test("Activity 1", () {
      String content = File(folderPath + "jpg_gantt_activity_1_loc.html")
          .readAsStringSync();
      List<Map<String, dynamic>> result = parseGanttDuty(content);
      print(result);
    });

    test("Activity 2", () {
      String content = File(folderPath + "jpg_gantt_activity_2_loc.html")
          .readAsStringSync();
      List<Map<String, dynamic>> result = parseGanttDuty(content);
      print(result);
    });

    test("Activity 3", () {
      String content = File(folderPath + "jpg_gantt_activity_3_loc.html")
          .readAsStringSync();
      List<Map<String, dynamic>> result = parseGanttDuty(content);
      print(result);
    });

    test("Activity 4", () {
      String content = File(folderPath + "jpg_gantt_activity_4_loc.html")
          .readAsStringSync();
      List<Map<String, dynamic>> result = parseGanttDuty(content);
      print(result);
    });

    test("Activity 5", () {
      String content = File(folderPath + "jpg_gantt_activity_5_loc.html")
          .readAsStringSync();
      List<Map<String, dynamic>> result = parseGanttDuty(content);
      print(result);
    });
  });

  group("Crew parsing tests", () {

    String folderPath = "test/HTML files/crew/";

    test("WY101", () {
      String content = File(folderPath + 'wy101.html').readAsStringSync();
      var result = parseCrewPage(content);
      expect(result.length, 14);
      expect(result[0]['staff_number'], '91763');

      var dataCrewFO = result.firstWhere((data) => data['rank'] == 'FO');
      expect(dataCrewFO['name'], "IDRIS AL SIYABI");

      expect(
        result.firstWhere((data) => data['staff_number'] == '91357')['name'],
        'ADONA SALONGA');

      expect(
          result.firstWhere((data) => data['name'] == 'NAJI ABDULLAH AL SHUAIBI')['role'],
          'ALLCC MCT PGC');
    });

    test("WY601", () {
      String content = File(folderPath + 'wy601.html').readAsStringSync();
      var result = parseCrewPage(content);

      expect(result.length, 6);
      expect(result.firstWhere((data) => data['rank'] == 'CAPT')['name'],
          "DENIS OKAN");
    });

    test("WY824", () {
      String content = File(folderPath + 'wy824.html').readAsStringSync();
      var result = parseCrewPage(content);

      expect(result.length, 12);

      expect(result.firstWhere((data) => data['rank'] == 'FO')['name'],
          "LANDRY GAGNE");
      expect(result.firstWhere((data) => data['rank'] == 'FO')['staff_number'],
          "93429");
    });

    test("WY673", () {
      String content = File(folderPath + 'wy673.html').readAsStringSync();
      var result = parseCrewPage(content);

      print(result);

      expect(result.length, 12);
    });
  });
}
