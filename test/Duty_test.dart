import 'dart:convert';

import 'package:test/test.dart';
import 'package:wyob/objects/Duty.dart';


void main() {
  
  String jsonDutyStringExample = '{"nature": "DUTY_NATURE.FLIGHT","code": "851-04","startTime": "30Apr2017 08:15 +04:00","endTime": "30Apr2017 21:40 +08:00","startPlace": "MCT","endPlace": "CAN","flights": [{"startTime":"30Apr2017 09:45 +04:00","endTime":"30Apr2017 21:10 +08:00","startPlace":"MCT","endPlace":"CAN","flightNumber":"WY851"}]}';

  test("DUTY_NATURE enum", () {
    DUTY_NATURE nature = DUTY_NATURE.LAYOVER;
    expect(nature.toString(), "DUTY_NATURE.LAYOVER");
    expect(getDutyNatureFromString("DUTY_NATURE.FLIGHT"), DUTY_NATURE.FLIGHT);
  });

  group("DateTime and Duration tests", () {

    test("Empty Duty toString()", () {
      var duty = new Duty();
      expect(duty.toString(), '|UNKNOWN  |UNKNOWN  |XXX|DDMMMYYYY HH:MM|XXX|DDMMMYYYY HH:MM|+00:00|UNKNOWN|');
    });
  });

  group("JSON stuff", () {
    test("Duty.fromJson constructor", (){

    });
    
    // TODO: find out why it fails
    test("Duty.toJson() method test", () {
      Duty duty = new Duty.fromJson(jsonDutyStringExample);
      expect(duty.nature.toString(), 'DUTY_NATURE.FLIGHT');
    });
  });
  
}
