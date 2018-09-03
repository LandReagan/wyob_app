class WyobException implements Exception {

  final String msg;

  const WyobException([this.msg]);

  @override
  String toString() => this.msg ?? 'a WyobException with no message!';

  //TODO: Implement automatic logging of Exception.
}