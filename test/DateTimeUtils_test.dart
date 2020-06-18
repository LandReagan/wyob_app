import 'package:flutter_test/flutter_test.dart';
import "package:wyob/utils/DateTimeUtils.dart";

void main() {

  group("DateTimeToString function test", () {
    test("Basic", () {
      DateTime datetime = new DateTime(1978, 11, 15, 3, 40);
      String result = dateTimeToString(datetime);
      expect(result, equals("15Nov1978 03:40"));
    });

    test("With all leading zeros", () {
      DateTime datetime = new DateTime(1978, 1, 3, 3, 6);
      String result = dateTimeToString(datetime);
      expect(result, equals("03Jan1978 03:06"));
    });
  });

  group("StringToDateTime function tests", () {
    test("Basic", () {
      String txt = "15Nov1978 03:40";
      DateTime datetime = new DateTime(1978, 11, 15, 3, 40);
      expect(stringToDateTime(txt), equals(datetime));
    });
  });

  group("StringToDuration and DurationToString functions tests", () {
    test("Basic 1", () {
      String test1 = "+01:35";
      Duration duration1 = stringToDuration(test1);
      expect(test1, equals(durationToString(duration1)));
    });

    test("Basic 2", () {
      String test1 = "-09:01";
      Duration duration1 = stringToDuration(test1);
      expect(test1, equals(durationToString(duration1)));
    });
  });

  test('durationToDouble function test', () {
    Duration duration = Duration(hours: 1, minutes: 30);
    expect(durationToDouble(duration), 1.5);
  });

  group("AwareDT class tests", () {

    test("toString method", () {

      AwareDT awareDt = new AwareDT.fromDateTimes(
        new DateTime(1978, 11, 15, 03, 40),
        new DateTime(1978, 11, 15, 02, 40)
      );

      String testString = "15Nov1978 03:40 +01:00";

      expect(awareDt.toString(), testString);
    });

    test("fromIobString constructor test", () {
      String txt = "01Jul2018 21:05 (20:05)";
      AwareDT awareDT = new AwareDT.fromIobString(txt);
      String testString = "01Jul2018 21:05 +01:00";
      expect(awareDT.toString(), testString);
    });

    test("Tricky fromIobString constructor test", () {
      String txt = "01Jul2018 23:30 (01:30)";
      AwareDT awareDT = new AwareDT.fromIobString(txt);
      String testString = "01Jul2018 23:30 -02:00";
      expect(awareDT.toString(), testString);
    });

    test("fromString method test", () {
      String txt = "15Nov1978 03:40 +01:00";
      AwareDT awareDT = new AwareDT.fromString(txt);
      print(awareDT.toString());
      expect(awareDT.utc, equals(stringToDateTime("15Nov1978 02:40")));
    });

    test('Comparison operators', () {
      AwareDT awareDt1 = new AwareDT.fromDateTimes(
          new DateTime(1978, 11, 15, 03, 40),
          new DateTime(1978, 11, 15, 02, 40)
      );
      AwareDT awareDt2 = new AwareDT.fromDateTimes(
          new DateTime(1978, 11, 15, 05, 40),
          new DateTime(1978, 11, 15, 04, 40)
      );
      expect(awareDt1 < awareDt2, true);
      expect(awareDt2 > awareDt1, true);
      expect(awareDt1 > awareDt2, false);
      expect(awareDt2 < awareDt1, false);
      expect(awareDt2 > awareDt2, false);
      expect(awareDt2 < awareDt2, false);
      expect(awareDt2 >= awareDt2, true);
      expect(awareDt2 <= awareDt2, true);
    });
  });
}
