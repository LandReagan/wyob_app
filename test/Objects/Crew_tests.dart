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
    var dummyCpt = {
      "surname": "Garraio",
      "first_name": "Jean-Pierre",
      "staff_number": "92222",
      "role": "CPT",
      "rank": "TCPT"
    };

    var dummyFo = {
      "surname": "Gagne",
      "first_name": "Landry",
      "staff_number": "93429",
      "role": "FO",
      "rank": "FO"
    };

    test("Crew ctor and add method", () {
      Crew crew = Crew();
      crew.addMember(CrewMember.fromMap(dummyCpt));
      crew.addMember(CrewMember.fromMap(dummyFo));

      expect(
        crew.crewMembers.firstWhere((member) => member.rank == "FO").firstName,
        "Landry"
      );
    });
  });
}
