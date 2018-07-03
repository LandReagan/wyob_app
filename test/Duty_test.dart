import 'dart:io' show File;
import 'dart:convert' show json;

import 'package:test/test.dart';
import '../lib/Duty.dart';
import '../lib/Parsers.dart' show parseCheckinList;


void main() {
  
  String jsonDutyStringExample = "{\"nature\": \"FLIGHT\",\"code\": \"851-04\",\"startTime\": \"30Apr2017 08:15 +04:00\",\"endTime\": \"30Apr2017 21:40 +08:00\",\"startPlace\": \"MCT\",\"endPlace\": \"CAN\",\"flights\": \"[{\"startTime\":\"30Apr2017 09:45 +04:00\",\"endTime\":\"30Apr2017 21:10 +08:00\",\"startPlace\":\"MCT\",\"endPlace\":\"CAN\",\"flightNumber\":\"WY851\"}, ]\"}";

  test("Nature getter unit test", () {
    var duty = new Duty();
    duty.nature = "FLIGHT";
    expect(duty.nature, equals("FLIGHT"));
  });

  group("DateTime and Duration tests", () {

    test("Empty Duty toString()", () {
      var duty = new Duty();
      expect(duty.toString(), '|UNKNOWN  |UNKNOWN  |XXX|DDMMMYYYY HH:MM|XXX|DDMMMYYYY HH:MM|+00:00|');
    });
  });

  group("JSON stuff", () {
    test("Duty.fromJson constructor", (){

    });
    
    test("Duty.toJson() method test", () {
      Duty duty = new Duty.fromJson(jsonDutyStringExample);
      print(duty);
    });
  });
  
}