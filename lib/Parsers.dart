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

void main() {

  File outFile = new File("checkin.json");
  File inFile = new File("test/HTML files/checkinlist.htm");

  String content = inFile.readAsStringSync();
  List<Map<String, String>> checkinList = parseCheckinList(content);

  String out = json.encode(checkinList);
  outFile.writeAsStringSync(out);
}