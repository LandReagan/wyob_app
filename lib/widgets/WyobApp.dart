import 'package:flutter/material.dart';
import 'package:logger_flutter/logger_flutter.dart';

import 'package:wyob/pages/HomePage.dart';


class WyobApp extends StatelessWidget {

  Widget build(BuildContext context) {
    return MaterialApp(
        home: HomePage(),
    );
  }
}
