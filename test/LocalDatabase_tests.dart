import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:wyob/data/LocalDatabase.dart';
import 'package:wyob/objects/Crew.dart';

class LocalDatabaseMock extends Mock implements LocalDatabase {}


void main() {

  group('LocalDatabase tests:', () {

    LocalDatabase database;

    setUp(() async {
      database = LocalDatabase();
      await database.setCredentials("Dummy", "Dummy", 'FO');
    });

    test("Initial tests", () async {
      await database.connect();
      expect(database.rootData.keys.contains("user_data"), true);
    });

    group('updateFromGantt tests', () {
      setUp(() async {
        database = LocalDatabase();
        await database.setCredentials("Dummy", "Dummy", 'FO');
      });

      test('General test', () async {
        await database.connect();
        // await database.updateFromGantt();
      });
    });

    group("Crew stuff", () {

      setUpAll(() async {
        database = LocalDatabase();
        await database.setCredentials("Dummy", "Dummy", 'FO');
      });

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

      test("Crew getter", () async {
        await database.connect();
        await database.reset();
        await database.setCredentials("Dummy", "Dummy", "FO");
        Crew crew = await database.getCrewInformation(DateTime.now(), "WY824");
        expect(crew, null);
        await database.setCrewInformation(
            DateTime.now(), 'WY824', Crew.fromMap(dummyCrew));
        crew = await database.getCrewInformation(DateTime.now(), "WY824");
        expect(crew, isNotNull);
        expect(crew.crewMembers.where((member) => member.rank == 'FO').first.surname, "LANDRY GAGNE");
      });
    });
  });
}
