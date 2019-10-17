import 'package:flutter_test/flutter_test.dart';

enum CONNECTOR_STATUS {
  OFF,
  CONNECTING,
  OFFLINE,
  LOGIN_FAILED,
  CONNECTED,
  AUTHENTIFIED,
  FETCHING_GANTT_TABLE,
  FETCHING_DUTY,
  ERROR,
}

class IobConnectorData {
  
  CONNECTOR_STATUS _status;
  int _dutyNumber = 0;
  int _totalDutiesNumber = 0;

  IobConnectorData(
      CONNECTOR_STATUS status,
      [int dutyNumber = 0, int totalDutiesNumber = 0]) :
    _status = status,
    _dutyNumber = dutyNumber, _totalDutiesNumber = totalDutiesNumber;
  
  CONNECTOR_STATUS get status => _status;
  int get dutyNumber => _dutyNumber;
  int get totalDutiesNumber => _totalDutiesNumber;

  set status(CONNECTOR_STATUS newStatus) {
    if (newStatus != null) _status = newStatus;
  }

  String get statusString {
    switch (_status) {
      case CONNECTOR_STATUS.OFF:
        return "OFF";
        break;
      case CONNECTOR_STATUS.CONNECTING:
        return "CONNECTING...";
        break;
      case CONNECTOR_STATUS.CONNECTED:
        return "CONNECTED!";
        break;
      case CONNECTOR_STATUS.AUTHENTIFIED:
        return "AUTHENTIFIED!";
        break;
      case CONNECTOR_STATUS.FETCHING_GANTT_TABLE:
        return "FETCHING GANTT TABLE...";
        break;
      case CONNECTOR_STATUS.FETCHING_DUTY:
        return "FETCHING DUTY: " +
            dutyNumber.toString() + " / " + totalDutiesNumber.toString();
        break;
      case CONNECTOR_STATUS.OFFLINE:
        return "DEVICE OFFLINE!";
        break;
      case CONNECTOR_STATUS.ERROR:
        return "AN ERROR HAS OCCURED!";
        break;
      default:
        return "???";
    }
  }
  
}
