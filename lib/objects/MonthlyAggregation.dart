import 'package:wyob/data/LocalDatabase.dart';
import 'package:wyob/utils/DateTimeUtils.dart';

/// Lazy Class designed to aggregate Duty and Statistics (and others?) data
/// together, i.e. per month, in order to easily calculate / access to data
/// values that make sense to have monthly (accumulated block hours, etc.)
class MonthlyAggregation {

  final DateTime _monthStart;

  /// This DateTime shall be local
  MonthlyAggregation(this._monthStart);

  /// Getter to force monthStart being the first minute of the month.
  DateTime get monthStart => DateTime(_monthStart.year, _monthStart.month);
  /// Getter to get monthEnd representing the last minute of the month
  DateTime get monthEnd => DateTime(_monthStart.year, _monthStart.month + 1)
                              .subtract(Duration(minutes: 1));
  /// Getter to gather duties and statistics, as a List of
  /// Map {'duty': ..., 'stat': ...}
  List<Map<String, dynamic>> get dutiesAndStatistics =>
      LocalDatabase().getDutiesAndStatistics(this.monthStart, this.monthEnd);

  String get titleString =>
      getMonthFullString(monthStart.month) + ' ' + monthStart.year.toString();

}
