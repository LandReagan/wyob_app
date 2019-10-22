import 'package:logger/logger.dart';

/// Exception sub class used as super class for all exceptions used in the app.
/// It is a very simple extension of [Exception], only used to describe the
/// thrown exception by name (see sub classes) and with a message.
class WyobException implements Exception {

  final String msg;

  WyobException([this.msg]) {
    Logger().w(this.msg);
  }

  @override
  String toString() => this.msg ?? 'a WyobException with no message!';

  //TODO: Implement automatic logging of Exception.
}

// IobConnector exceptions
class WyobExceptionCredentials extends WyobException {
  WyobExceptionCredentials([String msg]) : super(msg);
}

class WyobExceptionOffline extends WyobException {
  WyobExceptionOffline([String msg]) : super(msg);
}

class WyobExceptionLogIn extends WyobException {
  WyobExceptionLogIn([String msg]) : super(msg);
}

class WyobExceptionDatabaseIntegrity extends WyobException {
  WyobExceptionDatabaseIntegrity([String msg]) : super(msg);
}

class WyobExceptionFtlIncomplete extends WyobException {
  WyobExceptionFtlIncomplete([String msg]) : super(msg);
}
