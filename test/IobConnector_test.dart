import 'package:test/test.dart';

import 'package:wyob/iob/IobConnect.dart';


void main() {
  test("getFromToGanttDuties method", () async {
    IobConnector connector = IobConnector();
    await connector.run('93429', '93429iob');
    await connector.getGanttMainTable();
    await connector.getFromToGanttDuties(connector.personId, DateTime.now(), DateTime.now().add(Duration(days: 3)));
  });
}
