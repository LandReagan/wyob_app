import 'package:wyob/objects/Duty.dart';

class Statistics {

  final Duty _duty;
  final Statistics _previous;

  Statistics(this._duty, [this._previous]);

  String get dutyID => _duty.id;

  Duration get accumulatedBlock {
    Duration result = Duration.zero;
    if (_previous != null) result += _previous.accumulatedBlock;
    if (_duty.isFlight) result += _duty.totalBlockTime;
    return result;
  }

  Duration get accumulatedDuty {
    Duration result = Duration.zero;
    if (_previous != null) result += _previous.accumulatedDuty;
    if (_duty.isWorkingDuty) result += _duty.duration;
    return result;
  }
}
