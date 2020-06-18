import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:wyob/iob/IobConnectorData.dart';

void main() {
  group("Constructors", () {
    test("Constructor with status only", () {
      var data = IobConnectorData(CONNECTOR_STATUS.OFF);
      expect(data.status, CONNECTOR_STATUS.OFF);
      expect(data.dutyNumber, 0);
      expect(data.totalDutiesNumber, 0);
    });

    test("Constructor with duty numbers", () {
      var data = IobConnectorData(CONNECTOR_STATUS.FETCHING_DUTY, 1, 20);
      expect(data.dutyNumber, 1);
      expect(data.totalDutiesNumber, 20);
      expect(data.statusString, "FETCHING DUTY: 1 / 20");
    });
  });

  group("Setters", () {
    test("Setter of status with null value", () {
      var data = IobConnectorData(CONNECTOR_STATUS.OFF);
      data.status = null;
      expect(data.status, CONNECTOR_STATUS.OFF);
    });

    test("Setter of status", () {
      var data = IobConnectorData(CONNECTOR_STATUS.OFF);
      data.status = CONNECTOR_STATUS.OFFLINE;
      expect(data.status, CONNECTOR_STATUS.OFFLINE);
    });
  });
}
