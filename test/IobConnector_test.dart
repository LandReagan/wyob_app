import 'package:test/test.dart';

import 'package:wyob/iob/IobConnector.dart';


void main() {

  test('Wrong credentials test', () async {
    IobConnector connector = IobConnector('', '');
    expect(connector.init(), throwsException);
  });

  test('IobConnector online tests', () async {
    IobConnector connector = IobConnector('93429', '93429iob');
    print(await connector.init());
  });
}
