import 'dart:math';

import 'package:test/test.dart';

import 'package:wyob/objects/Crew.dart';

void main() {
  group("CrewMember class unit tests", () {
    var dummy1map = {
      "surname": "Gagne",
      "first_name": "Landry",
      "staff_number": "93429",
      "role": "FO",
      "rank": "FO"
    };

    var dummy2map = {
      "surname": "Gagne",
      "first_name": "Landry",
    };

    test("fromMap ctor", () {
      CrewMember landry1 = CrewMember.fromMap(dummy1map);

      expect(landry1.surname, "Gagne");
      expect(landry1.firstName, "Landry");
      expect(landry1.staffNumber, "93429");
      expect(landry1.role, "FO");
      expect(landry1.rank, "FO");

      CrewMember landry2 = CrewMember.fromMap(dummy2map);

      expect(landry2.surname, "Gagne");
      expect(landry2.firstName, "Landry");
      expect(landry2.staffNumber, "");
      expect(landry2.role, "");
      expect(landry2.rank, "");
    });
  });

  group("Crew class unit tests", () {
    var dummyCrew1 = [
      {
        "staff_number": "90693",
        "name": "MOHAMED ALHARMALI",
        "role": "330 MCT CAPT",
        "rank": "CAPT"
      },
      {
        "staff_number": "93429",
        "name": "LANDRY GAGNE",
        "role": "330 MCT FO",
        "rank": "FO"
      },
      {
        "staff_number": "92412",
        "name": "ADNAN AL BALUSHI",
        "role": "ALLCC MCT CD",
        "rank": "CD"
      },
      {
        "staff_number": "92181",
        "name": "OTHMAN AL SHEHHI",
        "role": "ALLCC MCT PGC",
        "rank": "PGC"
      },
      {
        "staff_number": "92260",
        "name": "ALI ABDULLAH AL ZAKHWANI",
        "role": "ALLCC MCT PGC",
        "rank": "PGC"
      },
      {
        "staff_number": "93617",
        "name": "CHUTIKA NARONGSAKSUKUM",
        "role": "ALLCC MCT PGC",
        "rank": "PGC"
      },
      {
        "staff_number": "93618",
        "name": "NAWAPUN NURAPAK",
        "role": "ALLCC MCT PGC",
        "rank": "PGC"
      },
      {
        "staff_number": "95328",
        "name": "FARHANA MOHD BINTI FAUZAL",
        "role": "ALLCC MCT CA",
        "rank": "CA"
      },
      {
        "staff_number": "95347",
        "name": "SALHA SAID SALUM",
        "role": "ALLCC MCT CA",
        "rank": "CA"
      },
      {
        "staff_number": "95359",
        "name": "HASSAN HAMED AL HARTHI YAHYA",
        "role": "ALLCC MCT CA",
        "rank": "CA"
      },
      {
        "staff_number": "95612",
        "name": "USAMA DAD MOHAMED ALBULUSHI FAQIR",
        "role": "ALLCC MCT CA",
        "rank": "CA"
      },
      {
        "staff_number": "95884",
        "name": "AHLAM AHMED ALRASHDI",
        "role": "ALLCC MCT CA",
        "rank": "CA"
      }
    ];

    var dummyCrew2 = [
      {
        "staff_number": "95569",
        "name": "DENIS OKAN",
        "role": "737 MCT CAPT",
        "rank": "CAPT"
      },
      {
        "staff_number": "95803",
        "name": "SAID AL BUSAIDI",
        "role": "737 MCT FO",
        "rank": "FO"
      },
      {
        "staff_number": "91569",
        "name": "SU WAI HNIN",
        "role": "ALLCC MCT CD",
        "rank": "CD"
      },
      {
        "staff_number": "95079",
        "name": "ABDUL MAJED AL BALUSHI",
        "role": "ALLCC MCT CA",
        "rank": "CA"
      },
      {
        "staff_number": "95128",
        "name": "KANOKWAN SRITAN",
        "role": "ALLCC MCT CA",
        "rank": "CA"
      },
      {
        "staff_number": "96387",
        "name": "JOSELLE MABAL ESPALDON",
        "role": "ALLCC MCT CA",
        "rank": "CA"
      }
    ];

    test("Dummy crew 1", () {
      var crew = Crew.fromParser(dummyCrew1);
      expect(crew.crewMembers.length, 12);
      expect(
          crew.crewMembers
              .firstWhere((crewMember) => crewMember.surname == 'LANDRY GAGNE')
              .staffNumber,
          '93429');
      var convertedCrew = Crew.fromJson(crew.crewAsJson);
      expect(
          convertedCrew.crewMembers
              .firstWhere((crewMember) => crewMember.surname == 'LANDRY GAGNE')
              .staffNumber,
          '93429');
    });

    test("Dummy crew 2", () {
      var crew = Crew.fromParser(dummyCrew2);
      expect(crew.crewMembers.length, 6);
      expect(
          crew.crewMembers
              .firstWhere((crewMember) => crewMember.staffNumber == '91569')
              .role,
          'CD');
    });
  });
}
