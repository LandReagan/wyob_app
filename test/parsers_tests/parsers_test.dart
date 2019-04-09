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
  });
}
