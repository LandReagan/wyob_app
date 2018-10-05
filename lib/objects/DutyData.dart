import 'Duty.dart';
import 'package:wyob/utils/DateTimeUtils.dart';


/// Convenience class for data gathering between duties and the update details.
class DutyData {

  List<Duty> _duties;
  AwareDT _lastUpdate;

  DutyData(this._lastUpdate, this._duties);

  AwareDT get lastUpdate => _lastUpdate;
  List<Duty> get duties => _duties;
}