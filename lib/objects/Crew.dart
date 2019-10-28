class Crew {
  List<CrewMember> _crewMembers;
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
}
