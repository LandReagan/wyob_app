import 'dart:math';

import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:wyob/data/LocalDatabase.dart';

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

}
