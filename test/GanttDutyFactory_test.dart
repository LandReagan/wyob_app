import 'dart:io' show File;
import 'dart:math';
import 'package:test/test.dart';

import 'package:wyob/iob/GanttDutyFactory.dart' show GanttDutyFactory;
import 'package:wyob/objects/Duty.dart';
import 'package:wyob/objects/Flight.dart';
import 'package:wyob/utils/Parsers.dart' show parseGanttDuty;

void main() {

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

  test('duty_gantt_example', () {
    File file = File('test/HTML files/duty_gantt_example_Local.html');
    String fileText = file.readAsStringSync();
    List<Map<String, dynamic>> data = parseGanttDuty(fileText);
    print(data);
  });
}
