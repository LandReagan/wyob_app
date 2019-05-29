import 'package:wyob/objects/Duty.dart';

class Statistics {

  final Duty _duty;

  Statistics(this._duty);

  String get dutyID => _duty.id;

  Duration sevenDaysDutyAccumulation;
  Duration twentyEightDaysDutyAccumulation;
  Duration oneYearDutyDaysAccumulation;

  Duration twentyEightDaysBlockAccumulation;
  Duration oneYearBlockAccumulation;

  // Setters from LocalDatabase.buildStatistics method

}
