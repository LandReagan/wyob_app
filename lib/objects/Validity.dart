import 'package:flutter/material.dart';

class Validity {
  String name;
  DateTime deadline;
  Duration amberPeriod;

  Validity(this.name, this.deadline, {this.amberPeriod = Duration.zero});

  bool get isAmber {
    if (this.isRed) return false;
    return DateTime.now().toUtc().isAfter(deadline.toUtc().subtract(amberPeriod));
  }

  bool get isRed => DateTime.now().toUtc().isAfter(deadline.toUtc());
}