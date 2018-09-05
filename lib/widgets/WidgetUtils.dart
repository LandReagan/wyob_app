import 'package:flutter/material.dart';


/// groups utility functions in this static class
class WidgetUtils {

  static getIconFromDutyNature(String dutyNature) {
    switch (dutyNature) {
      case 'FLIGHT':
        return Image.asset('graphics/icons/plane-50.png');
        break;

      case 'LEAVE':
        return Image.asset('graphics/icons/Coconut-50.png');
        break;

      case 'STDBY':
        return Image.asset('graphics/icons/StandByIcon2-50.png');
        break;

      case 'OFF':
        return Image.asset('graphics/icons/OffIcon-50.png');
        break;

      default:
        return new Icon(Icons.schedule);
    }
  }
}