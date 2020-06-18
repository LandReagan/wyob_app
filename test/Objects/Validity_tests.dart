import 'package:flutter_test/flutter_test.dart';
import 'package:wyob/objects/Validity.dart';

void main() {
  test('isAmber', () {
    Validity validity = Validity('A validity', DateTime(2020, 1, 1));
    expect(validity.isAmber, false);
  });
  test('isAmber, works only today...', () {
    Validity validity = Validity('A validity', DateTime(2020, 3, 15), amberPeriod: Duration(days: 30));
    expect(validity.isAmber, true);
  });
  test('isRed', () {
    Validity validity = Validity('A validity', DateTime(2020, 3, 1), amberPeriod: Duration(days: 30));
    expect(validity.isRed, true);
  });
  test('isRed but not', () {
    Validity validity = Validity('A validity', DateTime(2220, 3, 1), amberPeriod: Duration(days: 30));
    expect(validity.isRed, false);
  });
}