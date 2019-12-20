import 'package:intl/intl.dart';

class AcnPcn {

}

class StandardAircraftTirePressure {
  int _psi;
  double _kpcm2;
  double _MPa;

  StandardAircraftTirePressure.fromPsi(int psi) {
    _psi = psi;
  }

  int get psi => _psi;

  @override
  String toString() {
    return 'PSI:' + psi.toString() + ' kg/cm2:' + (_kpcm2.toString() ?? '') +
        ' MPa:' + (_MPa.toString() ?? '');
  }
}

class Aircraft {

  String _name;
  int _maximumApronMass;
  int _operatingMassEmpty;
  StandardAircraftTirePressure _standardAircraftTirePressure;
  Map<String, dynamic> _pavementSubgrades;

  Aircraft([String name]) : _name = name;

  set maximumApronMass(int mass) {
    if (_operatingMassEmpty == null ||
          (_operatingMassEmpty != null && mass > _operatingMassEmpty)) {
      _maximumApronMass = mass;
    }
  }

  set operatingMassEmpty(int mass) {
    if (_maximumApronMass == null ||
        (_maximumApronMass != null && mass < _maximumApronMass)) {
      _operatingMassEmpty = mass;
    }
  }

  set standardTirePressurePsi(int pressure) {
    _standardAircraftTirePressure =
        StandardAircraftTirePressure.fromPsi(pressure);
  }

  set pavementSubgrades(Map<String, dynamic> data) {
    try {
      var dummy = data['rigid']['A']['max'];
      dummy = data['rigid']['A']['min'];
      dummy = data['rigid']['B']['max'];
      dummy = data['rigid']['B']['min'];
      dummy = data['rigid']['C']['max'];
      dummy = data['rigid']['C']['min'];
      dummy = data['rigid']['D']['max'];
      dummy = data['rigid']['D']['min'];
      dummy = data['flexible']['A']['max'];
      dummy = data['flexible']['A']['min'];
      dummy = data['flexible']['B']['max'];
      dummy = data['flexible']['B']['min'];
      dummy = data['flexible']['C']['max'];
      dummy = data['flexible']['C']['min'];
      dummy = data['flexible']['D']['max'];
      dummy = data['flexible']['D']['min'];
      _pavementSubgrades = data;
    } on Exception catch (e) {
      print(e);
    }
  }

  int get maximumApronMass => _maximumApronMass;
  int get operatingMassEmpty => _operatingMassEmpty;
  StandardAircraftTirePressure get standardAircraftTirePressure
      => _standardAircraftTirePressure;
  Map<String, dynamic> get pavementSubgrades => _pavementSubgrades;

  // High-level getters
  int getACN({int weight, PAVEMENT_TYPE pavementType, SUBGRADE_STRENGTH subgradeStrength}) {
    
  }

  @override
  String toString() {
    String result = _name ?? '';
    result += 'WEIGHTS: ' + maximumApronMass.toString() + ' - ' +
        operatingMassEmpty.toString() + '\n';
    result += 'TIRE PRESSURE: ' + standardAircraftTirePressure.toString() + '\n';
    result += '     RIGID:         FLEXIBLE:\n';
    result += '     A  B  C  D  - A  B  C  D\n';
    result += 'MAX: ' + pavementSubgrades['rigid']['A']['max'].toString() + ' ' +
        pavementSubgrades['rigid']['B']['max'].toString() + ' ' +
        pavementSubgrades['rigid']['C']['max'].toString() + ' ' +
        pavementSubgrades['rigid']['D']['max'].toString() + ' - ' +
        pavementSubgrades['flexible']['A']['max'].toString() + ' ' +
        pavementSubgrades['flexible']['B']['max'].toString() + ' ' +
        pavementSubgrades['flexible']['C']['max'].toString() + ' ' +
        pavementSubgrades['flexible']['D']['max'].toString() + '\n';
    result += 'MIN: ' + pavementSubgrades['rigid']['A']['min'].toString() + ' ' +
        pavementSubgrades['rigid']['B']['min'].toString() + ' ' +
        pavementSubgrades['rigid']['C']['min'].toString() + ' ' +
        pavementSubgrades['rigid']['D']['min'].toString() + ' - ' +
        pavementSubgrades['flexible']['A']['min'].toString() + ' ' +
        pavementSubgrades['flexible']['B']['min'].toString() + ' ' +
        pavementSubgrades['flexible']['C']['min'].toString() + ' ' +
        pavementSubgrades['flexible']['D']['min'].toString() + '\n';;
    return result;
  }
}

enum PAVEMENT_TYPE {R, F}
enum SUBGRADE_STRENGTH {A, B, C, D}
enum TIRE_PRESSURE_CATEGORY {W, X, Y, Z}
enum PAVEMENT_CALCULATION_METHOD {T, U}

class Runway {
  int _pcn;
  PAVEMENT_TYPE _pavement_type;
  SUBGRADE_STRENGTH _subgrade_strength;
  TIRE_PRESSURE_CATEGORY _tire_pressure_category;
  PAVEMENT_CALCULATION_METHOD _pavement_calculation_method;

  Runway(this._pcn, this._pavement_type, this._subgrade_strength,
      this._tire_pressure_category, this._pavement_calculation_method);

  Runway.fromString(String txt) {
    RegExp pcnRE = RegExp(r'(\d+)\/([R|F])\/([A-D])\/([W-Z])\/([T|U])');
    Match pcnMatch = pcnRE.firstMatch(txt);
    if (pcnMatch == null) return; // todo: Exception?
    _pcn = int.parse(pcnMatch[1]);
    switch (pcnMatch[2]) {
      case 'R':
        _pavement_type = PAVEMENT_TYPE.R;
        break;
      case 'F':
        _pavement_type = PAVEMENT_TYPE.F;
        break;
    }
    switch (pcnMatch[3]) {
      case 'A':
        _subgrade_strength = SUBGRADE_STRENGTH.A;
        break;
      case 'B':
        _subgrade_strength = SUBGRADE_STRENGTH.B;
        break;
      case 'C':
        _subgrade_strength = SUBGRADE_STRENGTH.C;
        break;
      case 'D':
        _subgrade_strength = SUBGRADE_STRENGTH.D;
        break;
    }
    switch (pcnMatch[4]) {
      case 'W':
        _tire_pressure_category = TIRE_PRESSURE_CATEGORY.W;
        break;
      case 'X':
        _tire_pressure_category = TIRE_PRESSURE_CATEGORY.X;
        break;
      case 'Y':
        _tire_pressure_category = TIRE_PRESSURE_CATEGORY.Y;
        break;
      case 'Z':
        _tire_pressure_category = TIRE_PRESSURE_CATEGORY.Z;
        break;
    }
    switch (pcnMatch[5]) {
      case 'T':
        _pavement_calculation_method = PAVEMENT_CALCULATION_METHOD.T;
        break;
      case 'U':
        _pavement_calculation_method = PAVEMENT_CALCULATION_METHOD.U;
        break;
    }
  }

  @override
  String toString() {
    String result = _pcn.toString() + '/';
    if (_pavement_type == PAVEMENT_TYPE.R) {
      result += 'R/';
    } else if (_pavement_type == PAVEMENT_TYPE.F) {
      result += 'F/';
    } else {
      result += '?/';
    }
    if (_subgrade_strength == SUBGRADE_STRENGTH.A) {
      result += 'A/';
    } else if (_subgrade_strength == SUBGRADE_STRENGTH.B) {
      result += 'B/';
    } else if (_subgrade_strength == SUBGRADE_STRENGTH.C) {
      result += 'C/';
    } else if (_subgrade_strength == SUBGRADE_STRENGTH.D) {
      result += 'D/';
    } else {
      result += '?/';
    }
    if (_tire_pressure_category == TIRE_PRESSURE_CATEGORY.W) {
      result += 'W/';
    } else if (_tire_pressure_category == TIRE_PRESSURE_CATEGORY.X) {
      result += 'X/';
    } else if (_tire_pressure_category == TIRE_PRESSURE_CATEGORY.Y) {
      result += 'Y/';
    } else if (_tire_pressure_category == TIRE_PRESSURE_CATEGORY.Z) {
      result += 'Z/';
    } else {
      result += '?/';
    }
    if (_pavement_calculation_method == PAVEMENT_CALCULATION_METHOD.T) {
      result += 'T';
    } else if (_pavement_calculation_method == PAVEMENT_CALCULATION_METHOD.U) {
      result += 'U';
    } else {
      result += '?';
    }
    return result;
  }
}