List<Aircraft> getAircrafts() {
  var aircrafts = <Aircraft>[];

  // Page 1534
  Aircraft a333BED = Aircraft('A333 BED');
  a333BED.maximumApronMass = 233900;
  a333BED.operatingMassEmpty = 125000;
  a333BED.standardTirePressurePsi = 210;
  a333BED.pavementSubgrades = {
    'rigid': {
      'A': {
        'max': 55,
        'min': 29
      },
      'B': {
        'max': 63,
        'min': 29
      },
      'C': {
        'max': 75,
        'min': 33
      },
      'D': {
        'max': 87,
        'min': 38
      },
    },
    'flexible': {
      'A': {
        'max': 59,
        'min': 28
      },
      'B': {
        'max': 63,
        'min': 29
      },
      'C': {
        'max': 74,
        'min': 32
      },
      'D': {
        'max': 100,
        'min': 39
      },
    }
  };

  // Page 1534
  Aircraft a333HIJ = Aircraft('A333 HIJ');
  a333HIJ.maximumApronMass = 235900;
  a333HIJ.operatingMassEmpty = 125000;
  a333HIJ.standardTirePressurePsi = 210;
  a333HIJ.pavementSubgrades = {
    'rigid': {
      'A': {
        'max': 55,
        'min': 29
      },
      'B': {
        'max': 63,
        'min': 28
      },
      'C': {
        'max': 75,
        'min': 32
      },
      'D': {
        'max': 87,
        'min': 37
      },
    },
    'flexible': {
      'A': {
        'max': 59,
        'min': 27
      },
      'B': {
        'max': 63,
        'min': 29
      },
      'C': {
        'max': 74,
        'min': 31
      },
      'D': {
        'max': 100,
        'min': 39
      },
    }
  };

  // Page 1534
  Aircraft a332 = Aircraft('A332');
  a333BED.maximumApronMass = 233900;
  a333BED.operatingMassEmpty = 120000;
  a333BED.standardTirePressurePsi = 206;
  a333BED.pavementSubgrades = {
    'rigid': {
      'A': {
        'max': 54,
        'min': 28
      },
      'B': {
        'max': 62,
        'min': 27
      },
      'C': {
        'max': 74,
        'min': 30
      },
      'D': {
        'max': 86,
        'min': 35
      },
    },
    'flexible': {
      'A': {
        'max': 58,
        'min': 26
      },
      'B': {
        'max': 63,
        'min': 27
      },
      'C': {
        'max': 73,
        'min': 30
      },
      'D': {
        'max': 98,
        'min': 36
      },
    }
  };

  aircrafts.addAll([a333BED, a333HIJ, a332]);
  return aircrafts;
}


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
    int acnMax;
    int acnEmpty;
    String pavementTypeString;
    String subgradeStrengthString;

  }

  String get name => _name;

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
String getPavementTypeLetter(PAVEMENT_TYPE type) {
  switch (type) {
    case PAVEMENT_TYPE.F:
      return 'F';
      break;
    case PAVEMENT_TYPE.R:
      return 'R';
      break;
    default:
      return null;
  }
}

enum SUBGRADE_STRENGTH {A, B, C, D}
String getSubgradeStrengthLetter(SUBGRADE_STRENGTH sub) {
  switch (sub) {
    case SUBGRADE_STRENGTH.A:
      return 'A';
      break;
    case SUBGRADE_STRENGTH.B:
      return 'B';
      break;
    case SUBGRADE_STRENGTH.C:
      return 'C';
      break;
    case SUBGRADE_STRENGTH.D:
      return 'D';
      break;
    default:
      return null;
  }
}
enum TIRE_PRESSURE_CATEGORY {W, X, Y, Z}
String getTirePressureCategoryLetter(TIRE_PRESSURE_CATEGORY cat) {
  switch (cat) {
    case TIRE_PRESSURE_CATEGORY.X:
      return 'X';
      break;
    case TIRE_PRESSURE_CATEGORY.Y:
      return 'Y';
      break;
    case TIRE_PRESSURE_CATEGORY.W:
      return 'W';
      break;
    case TIRE_PRESSURE_CATEGORY.Z:
      return 'Z';
      break;
    default:
      return null;
  }
}
enum PAVEMENT_CALCULATION_METHOD {T, U}
String getPavementCalculationMethodLetter(PAVEMENT_CALCULATION_METHOD method) {
  switch (method) {
    case PAVEMENT_CALCULATION_METHOD.T:
      return 'T';
      break;
    case PAVEMENT_CALCULATION_METHOD.U:
      return 'U';
      break;
    default:
      return null;
  }
}

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
    result += getPavementTypeLetter(_pavement_type) + '/';
    result += getSubgradeStrengthLetter(_subgrade_strength) + '/';
    result += getTirePressureCategoryLetter(_tire_pressure_category) + '/';
    result += getPavementCalculationMethodLetter(_pavement_calculation_method);
    return result;
  }
}