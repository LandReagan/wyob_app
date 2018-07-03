import "package:test/test.dart";
import "../lib/DateTimeUtils.dart";

void main() {

  group("DateTimeToString function test", () {
    test("Basic", () {
      DateTime datetime = new DateTime(1978, 11, 15, 3, 40);
      String result = DateTimeToString(datetime);
      expect(result, equals("15Nov1978 03:40"));
    });

    test("With all leading zeros", () {
      DateTime datetime = new DateTime(1978, 1, 3, 3, 6);
      String result = DateTimeToString(datetime);
      expect(result, equals("03Jan1978 03:06"));
    });
  });

  group("StringToDateTime function tests", () {
    test("Basic", () {
      String txt = "15Nov1978 03:40";
      DateTime datetime = new DateTime(1978, 11, 15, 3, 40);
      expect(StringToDateTime(txt), equals(datetime));
    });
  });

  group("StringToDuration and DurationToString functions tests", () {
    test("Basic 1", () {
      String test1 = "+01:35";
      Duration duration1 = StringToDuration(test1);
      expect(test1, equals(DurationToString(duration1)));
    });

    test("Basic 2", () {
      String test1 = "-09:01";
      Duration duration1 = StringToDuration(test1);
      expect(test1, equals(DurationToString(duration1)));
    });
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
      expect(awareDT.utc, equals(StringToDateTime("15Nov1978 02:40")));
    });
  });
}