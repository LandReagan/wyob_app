import 'package:wyob/utils/DateTimeUtils.dart';

class Statistics {

  final DateTime _day;

  Duration sevenDaysDutyAccumulation = Duration.zero;
  Duration twentyEightDaysDutyAccumulation = Duration.zero;
  Duration oneYearDutyDaysAccumulation = Duration.zero;

  Duration twentyEightDaysBlockAccumulation = Duration.zero;
  Duration oneYearBlockAccumulation = Duration.zero;

  bool sevenDaysDutyCompleteness = false;
  bool twentyEightDaysDutyCompleteness = false;
  bool oneYearDutyDaysCompleteness = false;

  bool twentyEightDaysBlockCompleteness = false;
  bool oneYearBlockCompleteness = false;

  Statistics(this._day);

  DateTime get day => _day;

  @override
  String toString() {
    return 'STAT: 7 DUTY ' + durationToString(sevenDaysDutyAccumulation) +
            '| 28 DUTY ' + durationToString(twentyEightDaysDutyAccumulation) +
            '| 365 DUTY ' + durationToString(oneYearDutyDaysAccumulation) +
            '| 28 BLOCK ' + durationToString(twentyEightDaysBlockAccumulation) +
            '| 365 BLOCK ' + durationToString(oneYearBlockAccumulation);
  }
}
