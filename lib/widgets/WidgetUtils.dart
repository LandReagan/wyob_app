import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wyob/objects/Duty.dart';

/// groups utility functions in this static class
class WidgetUtils {

  static getIconFromDutyNature(DUTY_NATURE dutyNature) {
    switch (dutyNature) {
      case DUTY_NATURE.FLIGHT:
        return Image.asset('graphics/icons/plane-50.png');
        break;

      case DUTY_NATURE.SIM:
        return Image.asset('graphics/icons/SimIcon-50.png');
        break;

      case DUTY_NATURE.LEAVE:
        return Image.asset('graphics/icons/Coconut-50.png');
        break;

      case DUTY_NATURE.STDBY:
        return Image.asset('graphics/icons/StandByIcon2-50.png');
        break;

      case DUTY_NATURE.OFF:
        return Image.asset('graphics/icons/OffIcon-50.png');
        break;

      case DUTY_NATURE.NOPS:
        return Image.asset('graphics/icons/nops-50.png');

      case DUTY_NATURE.LAYOVER:
        return Image.asset('graphics/icons/hotel.png');

      case DUTY_NATURE.GROUND:
        return Image.asset('graphics/icons/ground.png');

      default:
        return new ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 50.0, minHeight: 50.0
          ),
          child: Icon(Icons.schedule),
        );
    }
  }
}
