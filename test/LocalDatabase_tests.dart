import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:wyob/data/LocalDatabase.dart';
import 'package:wyob/objects/Duty.dart';
import 'package:wyob/objects/Crew.dart';
import 'package:wyob/utils/DateTimeUtils.dart';

class LocalDatabaseMock extends Mock implements LocalDatabase {}


void main() {
  test("Example 1 tests", () async {
    LocalDatabase db = LocalDatabase();
    await db.connect();
    expect(db.ready, true);
    expect(db.rootData.keys.contains("user_data"), true);
  });

  group('getDuties method', () {
    Duty duty1 = Duty();
    duty1.startTime = AwareDT.fromString('01Jan2019 00:05 +04:00');
    Duty duty2 = Duty();
    duty2.startTime = AwareDT.fromString('10Jan2019 00:00 +04:00');
    Duty duty3 = Duty();
    duty3.startTime = AwareDT.fromString('20Jan2019 00:00 +04:00');

    test('shall get all duties if dates are corresponding', () {

    });
  });

  group('updateFromGantt tests', () {
    LocalDatabase database = LocalDatabase();
    database.connect();

    test('should connect', () {
      expect(database.ready, true);
    });

    test('General test', () async {
      database = LocalDatabase();
      await database.connect();
      await database.updateFromGantt();
    });
  });

  group("Crew stuff", () {
    var database = LocalDatabase();
    database.connect();

    var dummyCrew = [
      {
        "surname": "MOHAMED ALHARMALI",
        "first_name": "",
        "staff_number": "90693",
        "rank": "CAPT",
        "role": "330 CAPT"
      },
      {
        "surname": "LANDRY GAGNE",
        "first_name": "",
        "staff_number": "93429",
        "rank": "FO",
        "role": "330 FO"
      },
      {
        "surname": "ADNAN AL BALUSHI",
        "first_name": "",
        "staff_number": "92412",
        "rank": "CD",
        "role": "CD"
      },
      {
        "surname": "OTHMAN AL SHEHHI",
        "first_name": "",
        "staff_number": "92181",
        "rank": "PGC",
        "role": "PGC"
      },
      {
        "surname": "ALI ABDULLAH AL ZAKHWANI",
        "first_name": "",
        "staff_number": "92260",
        "rank": "PGC",
        "role": "PGC"
      },
      {
        "surname": "CHUTIKA NARONGSAKSUKUM",
        "first_name": "",
        "staff_number": "93617",
        "rank": "PGC",
        "role": "PGC"
      },
      {
        "surname": "NAWAPUN NURAPAK",
        "first_name": "",
        "staff_number": "93618",
        "rank": "PGC",
        "role": "PGC"
      },
      {
        "surname": "FARHANA MOHD BINTI FAUZAL",
        "first_name": "",
        "staff_number": "95328",
        "rank": "CA",
        "role": "CA"
      },
      {
        "surname": "SALHA SAID SALUM",
        "first_name": "",
        "staff_number": "95347",
        "rank": "CA",
        "role": "CA"
      },
      {
        "surname": "HASSAN HAMED AL HARTHI YAHYA",
        "first_name": "",
        "staff_number": "95359",
        "rank": "CA",
        "role": "CA"
      },
      {
        "surname": "USAMA DAD MOHAMED ALBULUSHI FAQIR",
        "first_name": "",
        "staff_number": "95612",
        "rank": "CA",
        "role": "CA"
      },
      {
        "surname": "AHLAM AHMED ALRASHDI",
        "first_name": "",
        "staff_number": "95884",
        "rank": "CA",
        "role": "CA"
      }
    ];

    test("Crew getter", () {
      database.reset();
      expect(database.getCrewInformation(DateTime.now(), "WY824"), null);
      database.setCrewInformation(
          DateTime.now(), 'WY824', Crew.fromMap(dummyCrew));
      print(database);
    });
  });
}
