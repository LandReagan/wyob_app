import 'package:test/test.dart';
import 'dart:io';

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
    File input = File("test/HTML files/duty_gantt_example.html");
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
}
