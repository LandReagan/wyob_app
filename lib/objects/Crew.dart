// For tests only, to be removed
Crew getDummyCrew() {
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

  var dummyCD = {
    "surname": "Al Balushi",
    "first_name": "Mohamed",
    "staff_number": "92345",
    "role": "CD",
    "rank": "CD"
  };

  Crew crew = Crew();
  crew.addMember(CrewMember.fromMap(dummyCpt));
  crew.addMember(CrewMember.fromMap(dummyFo));
  crew.addMember(CrewMember.fromMap(dummyCD));

  return crew;
}

class Crew {

  List<CrewMember> _crewMembers;

  List<CrewMember> get crewMembers => _crewMembers;

  void addMember(CrewMember newMember) {
    if (_crewMembers == null) {
      _crewMembers = <CrewMember>[];
    } else {
      _crewMembers.removeWhere((member) => member.isSame(newMember));
    }
    _crewMembers.add(newMember);
  }

  List<Map<String, String>> get crewMembersMap {
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

  CrewMember.fromMap(Map<String, String> map) {
    _surname = map['surname'];
    _firstName = map['first_name'];
    _staffNumber = map['staff_number'];
    _rank = map['rank'];
    _role = map['role'];
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
}
