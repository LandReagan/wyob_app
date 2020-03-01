import 'dart:convert' show jsonEncode, jsonDecode;

var dummyCrew = [
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

Crew getDummyCrew() => Crew.fromParser(dummyCrew);

class Crew {

  List<CrewMember> _crewMembers;

  Crew.fromJson(String jsonString) {
    List<dynamic> dataList = jsonDecode(jsonString);
    for (var data in dataList) {
      addMember(CrewMember.fromMap(data));
    }
  }

  Crew.fromMap(List<Map<String, dynamic>> dataList) {
    for (var data in dataList) {
      addMember(CrewMember.fromMap(data));
    }
  }

  Crew.fromParser(List<Map<String, dynamic>> dataList) {
    for (var data in dataList) {
      addMember(CrewMember.fromParserMap(data));
    }
  }

  List<CrewMember> get crewMembers => _crewMembers;

  void addMember(CrewMember newMember) {
    if (_crewMembers == null) {
      _crewMembers = <CrewMember>[];
    } else {
      _crewMembers.removeWhere((member) => member.isSame(newMember));
    }
    _crewMembers.add(newMember);
  }

  List<Map<String, String>> get crewAsMap {
    List<Map<String, String>> map = [];
    for (var member in crewMembers) {
      map.add({
        "surname": member.surname,
        "first_name": member.firstName,
        "staff_number": member.staffNumber,
        "rank": member.rank,
        "role": member.role
      });
    }
    return map;
  }

  String get crewAsJson => jsonEncode(crewAsMap);

  @override
  String toString() {
    String result = "";
    crewMembers.forEach((crewMember) => result += crewMember.toString() + '\n');
    return result;
  }
}

class CrewMember {

  String _surname;
  String _firstName;
  String _staffNumber;
  String _rank;
  String _role;

  CrewMember({
      String surname,
      String firstName,
      String staffNumber,
      String rank,
      String role})
      : _surname = surname,
        _firstName = firstName,
        _staffNumber = staffNumber,
        _rank = rank,
        _role = role;

  CrewMember.fromMap(Map<String, dynamic> map) {
    _surname = map['surname'].toString();
    _firstName = map['first_name'].toString();
    _staffNumber = map['staff_number'].toString();
    _rank = map['rank'].toString();
    _role = map['role'].toString();
  }

  CrewMember.fromParserMap(Map<String, dynamic> data) {
    _surname = data['name'];
    _staffNumber = data['staff_number'];
    _rank = data['rank'];
    _role = data['role'];

    _role = _role.replaceAll("ALLCC MCT ", "");
    _role = _role.replaceAll(" MCT", "");
  }

  String get firstName => _firstName ?? "";
  String get surname => _surname ?? "";
  String get staffNumber => _staffNumber ?? "";
  String get role => _role ?? "";
  String get rank => _rank ?? "";

  bool isSame(CrewMember other) {
    if (this.staffNumber == other.staffNumber) return true;
    return false;
  }

  @override
  String toString() {
    return rank + " " + surname + " " + staffNumber + " " + role;
  }
}
