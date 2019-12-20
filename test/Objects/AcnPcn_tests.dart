import 'package:test/test.dart';
import 'package:wyob/objects/AcnPcn.dart';

void main() {

  group('Runway tests', () {
    test('Runway fromString constructor', () {
      Runway runway = Runway.fromString('80/R/B/W/T');
      expect(runway.toString(), '80/R/B/W/T');
      Runway runway2 = Runway.fromString('69/F/C/Y/T');
      expect(runway2.toString(), '69/F/C/Y/T');
    });
  });

  group('Aircraft tests', () {
    test('Setters', () {
      Aircraft A333 = Aircraft('A333');
      A333.maximumApronMass = 233900;
      A333.operatingMassEmpty = 125000;
      A333.standardTirePressurePsi = 210;
      A333.pavementSubgrades = {
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
          }
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
          }
        }
      };

      print(A333);

      expect(A333.maximumApronMass, 233900);
      expect(A333.operatingMassEmpty, 125000);
      expect(A333.standardAircraftTirePressure.psi, 210);
      expect(A333.pavementSubgrades['flexible']['C']['min'], 32);
    });
  });
}