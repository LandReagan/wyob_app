import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:wyob/data/LocalDatabase.dart';
import 'package:wyob/objects/Duty.dart';
import 'package:wyob/utils/DateTimeUtils.dart';

class LocalDatabaseMock extends Mock implements LocalDatabase {}


void main() {

  test("should return readiness at false on constructor (before connection)", () async {
    LocalDatabase db = LocalDatabase();
    expect(db.ready, false);
  });

  test("Example 1 tests", () async {
    LocalDatabase db = LocalDatabase();
    await db.connect();
    expect(db.ready, true);
    expect(db.rootData.keys.contains("user_data"), true);
  });

  group('getDuties method', () {
    Duty duty1 = Duty();
    duty1.startTime = AwareDT.fromString('01Jan2019 00:05 +04:00');
    Duty duty2 = Duty();
    duty2.startTime = AwareDT.fromString('10Jan2019 00:00 +04:00');
    Duty duty3 = Duty();
    duty3.startTime = AwareDT.fromString('20Jan2019 00:00 +04:00');

    test('shall get all duties if dates are corresponding', () {

    });

  });

  group('updateFromGantt tests', () {
    LocalDatabase database = LocalDatabase();
    database.connect();

    test('should connect', () {
      expect(database.ready, true);
    });

    test('empty parameters test', () async {
      await database.updateFromGantt();
    });
  });
}
