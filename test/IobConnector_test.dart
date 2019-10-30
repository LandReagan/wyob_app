import 'dart:math';

import 'package:test/test.dart';
import 'package:wyob/WyobException.dart';

import 'package:wyob/iob/IobConnector.dart';


void main() {

  test('Wrong credentials test', () async {
    IobConnector connector = IobConnector();
    expect(await connector.init(), throwsA(TypeMatcher<WyobException>()));
  });

  test('IobConnector online tests', () async {
    IobConnector connector = IobConnector();
    connector.setCredentials("93429", "93429iob");
    expect(await connector.init(), returnsNormally);
  });

  group("Crew information fetching", () {

    IobConnector connector = IobConnector();

    setUp(() async {
      connector.setCredentials("93429", "93429iob!");
      await connector.init();
    });

    test("Connection test", () {
      expect(connector.bigCookie, isNotNull);
    });

  });
}
