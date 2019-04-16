import 'package:test/test.dart';

import 'package:wyob/iob/IobConnect.dart';


void main() {
  test("getFromToGanttDuties method", () async {
    IobConnector connector = IobConnector('93429', '93429iob');
    await connector.run();
    await connector.getGanttMainTable();
    String nextThreeDays =
      await connector.getFromToGanttDuties(
        DateTime.now(), DateTime.now().add(Duration(days: 3)));
    print(nextThreeDays);
  });
}
