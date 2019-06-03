import 'dart:io';
import 'dart:convert' show json;

List<Map<String, String>> parseCheckinList(String txt) {

  List<Map<String, String>> checkinList = new List();

  // 1. Get the headers

  List<String> headers = new List();
  RegExp headerRegExp = new RegExp(
  r'<th>(\S*)</th>'
  );
  var matches = headerRegExp.allMatches(txt);
  
  for (var match in matches) {
    headers.add(match.group(1));
  }

  // 2. Get table rows

  RegExp rowRegExp = new RegExp(
    r"<tr>\s+(<td class=\Slistitem(?:_alert)?_0\S>[\S\s]*?</td>)+\s+</tr>",
    multiLine: true,
  );

  matches = rowRegExp.allMatches(txt);

  for (var match in matches) {
    String rowTxt = match.group(0);
    rowTxt = rowTxt.replaceAll(new RegExp(r'\s+'), " ");
    rowTxt = rowTxt.replaceAll(new RegExp(r'<tr>'), "");
    rowTxt = rowTxt.replaceAll(new RegExp(r'</tr>'), "");
    rowTxt = rowTxt.replaceAll(new RegExp(r"<td class=\Slistitem[\S\s]*?>"), "");
    rowTxt = rowTxt.replaceAll(new RegExp(r'</td>'), " - ");
    rowTxt = rowTxt.replaceAll(new RegExp(r'<td>'), "");

    List<String> fields = rowTxt.split(" - ");
    fields.removeLast();
    List<String> trimFields = new List();
    for (String field in fields) {
      trimFields.add(field.trim());
    }
    checkinList.add(new Map.fromIterables(headers, trimFields));
  }
  return checkinList;
}

List<Map<String, String>> parseGanttMainTable(String text) {
  /// In a GANTT main table, looks for the persAllocId
  List<Map<String, String>> data = [];
  RegExp boxRE = RegExp(r'<g id="\S+?\.bar[\S|\s]+?personId=(\d+)[\S|\s]+?persAllocId=(\d+)[\S|\s]+?_over\("(\S+?):[\S|\s]+?<text[\S|\s]+?>([\S|\s]+?)<');
  List<Match> boxMatches = boxRE.allMatches(text).toList();
  for (var match in boxMatches) {
    data.add({
      'personId': match[1],
      'persAllocId': match[2],
      'type': match[3] == 'Pairing' ? 'Trip' : 'Acy'
    });
  }
  return data;
}

List<Map<String, dynamic>> parseGanttDuty(String text) {
  /// parses the GANTT page for a single rotation or duty (if not flight).
  /// There may be several duties.
  List<Map<String, dynamic>> data = [];

  // Flight duty...
  RegExp dutiesSectionRE = RegExp(r'Discretion Rest[\S|\s]+?(<tr[\S|\s]+?)</table>');
  Match dutiesSectionM = dutiesSectionRE.firstMatch(text);
  if (dutiesSectionM != null) {
    String dutiesSection = dutiesSectionM[1];

    RegExp dutiesFieldRE = RegExp(r"<td[\S|\s]*?>([\S|\s]*?)</td>");
    List<Match> dutiesFieldMatches = dutiesFieldRE.allMatches(dutiesSection)
        .toList();
    int index = 0;
    for (int i = 0; i < dutiesFieldMatches.length; i++) {
      String value = dutiesFieldMatches[i][1];
      switch (i % 7) {
        case 0:
          index = int.parse(value) - 1;
          data.add(Map());
          break;
        case 1:
          data[index]['date'] = value;
          break;
        case 2:
          data[index]['start_time'] = value;
          break;
        case 3:
          data[index]['end_time'] = value;
          break;
        case 4:
          data[index]['duty_hours'] = value;
          break;
        case 5:
          data[index]['rest'] = value;
          break;
        case 6:
          data[index]['captain_discretion_rest'] = value;
          break;
      }
    }

    RegExp flightsSectionRE = RegExp(
        r'">Special Duty Code[\S|\s]+?(<tr[\S|\s]+?)</table>');
    Match flightsSectionM = flightsSectionRE.firstMatch(text);
    String flightsSection = flightsSectionM[1];

    RegExp specialDutyCodeRE = RegExp(
        r'<textarea[\S|\s]*?>([\S|\s]*?)</textarea>');

    RegExp flightsFieldRE = RegExp(r"<td[\S|\s]*?>([\S|\s]*?)</td>");
    List<Match> flightsFieldMatches = flightsFieldRE.allMatches(flightsSection)
        .toList();
    int flightIndex = 0;
    for (int i = 0; i < flightsFieldMatches.length; i++) {
      String value = flightsFieldMatches[i][1];
      switch (i % 13) {
        case 0:
          index = int.parse(value) - 1;
          if (data[index]['flights'] == null) data[index]['flights']  = [];
          break;
        case 1:
          flightIndex = int.parse(value) - 1;
          data[index]['flights'].add(Map());
          break;
        case 2:
          data[index]['flights'][flightIndex]['flight_number'] = value;
          break;
        case 3:
          data[index]['flights'][flightIndex]['date'] = value;
          break;
        case 4:
          data[index]['flights'][flightIndex]['from'] = value;
          break;
        case 5:
          data[index]['flights'][flightIndex]['start'] = value;
          break;
        case 6:
          data[index]['flights'][flightIndex]['to'] = value;
          break;
        case 7:
          data[index]['flights'][flightIndex]['end'] = value;
          break;
        case 8:
          data[index]['flights'][flightIndex]['wt'] = value;
          break;
        case 9:
          data[index]['flights'][flightIndex]['dvrt'] = value;
          break;
        case 10:
          data[index]['flights'][flightIndex]['flying_hours'] = value;
          break;
        case 11:
          data[index]['flights'][flightIndex]['a/c'] = value;
          break;
        case 12:
          Match valueM = specialDutyCodeRE.firstMatch(value);
          String specialValue = valueM[1];
          data[index]['flights'][flightIndex]['special_duty_code'] =
              specialValue;
          break;
      }
    }
  }

  // Other duties
  RegExp otherDutiesRE = RegExp(
      r'<td>Activity Type</td>\s+<td[\S|\s]+?value="(\S+)"[\S|\s]+?<td>Location</td>\s+<td[\S|\s]+?value="(\S+)"[\S|\s]+?<td>Start Date Time \(\S+?\)[\S|\s]+?value="([\S|\s]+?)"[\S|\s]+?value="([\S|\s]+?)"');
  Match otherDutiesM = otherDutiesRE.firstMatch(text);
  if (otherDutiesM != null) {
    data.add({
      'type': otherDutiesM[1],
      'from': otherDutiesM[2],
      'to': otherDutiesM[2],
      'start': otherDutiesM[3],
      'end': otherDutiesM[4]
    });
  }

  return data;
}

void main() {

  File outFile = new File("checkin.json");
  File inFile = new File("test/HTML files/checkinlist.htm");

  String content = inFile.readAsStringSync();
  List<Map<String, String>> checkinList = parseCheckinList(content);

  String out = json.encode(checkinList);
  outFile.writeAsStringSync(out);
}
