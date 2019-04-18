import 'dart:io' show File;
import 'dart:math';
import 'package:test/test.dart';

import 'package:wyob/iob/GanttDutyFactory.dart' show GanttDutyFactory;
import 'package:wyob/objects/Duty.dart';
import 'package:wyob/utils/Parsers.dart' show parseGanttDuty;

void main() {

  List<Map<String, String>> dummyDuties = [];
  File file1 = File('test/HTML files/duty_gantt_example.html');
  String fileText = file1.readAsStringSync();
  List<Map<String, String>> file1data = parseGanttDuty(fileText);

  test('shall return a list of duties', () {
    expect(GanttDutyFactory.run(dummyDuties).runtimeType.toString() == 'List<Duty>', true);
  });

  test('example should return 2 duties', () {
    expect(GanttDutyFactory.run(file1data).length, 2);
  });

  test('duty_gantt_example', () {
    File file = File('test/HTML files/duty_gantt_example.html');
    String fileText = file.readAsStringSync();
    List<Map<String, dynamic>> data = parseGanttDuty(fileText);
    print(data);
  });
}
