import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:escapement_of_the_grand_hour/enum/my_enums.dart';

class InputNotifier extends ChangeNotifier {
  String _cabinetControlNumber = '';
  ApparatusClassification _apparatusClassification = ApparatusClassification.englishLever;
  String _foundryOrManufacturer = '';
  String _eraOfProduction = '';
  RateDetectionClass _rateDetectionClass = RateDetectionClass.pocketWatch;
  BodyMetal _bodyMetal = BodyMetal.syntheticRuby;
  String _gauzeConfiguration = '';
  LockingMechanism _lockingMechanismType = LockingMechanism.detachedImpulse;
  String _fuelAndIlluminant = '';
  String _airInflowDesign = '';
  String _physicalProportions = '';
  PreservationStatus _preservationStatus = PreservationStatus.unknown;
  String _accompanyingGear = '';
  String _inspectorAndCollieryStamps = '';
  String _historicalContext = '';
  String _archivalNotes = '';
  String _photoPath = '';
  List<String> _tags = [];
  DateTime _dateAdded = DateTime.now();

  // Getters
  String get cabinetControlNumber => _cabinetControlNumber;
  ApparatusClassification get apparatusClassification => _apparatusClassification;
  String get foundryOrManufacturer => _foundryOrManufacturer;
  String get eraOfProduction => _eraOfProduction;
  RateDetectionClass get rateDetectionClass => _rateDetectionClass;
  BodyMetal get bodyMetal => _bodyMetal;
  String get gauzeConfiguration => _gauzeConfiguration;
  LockingMechanism get lockingMechanismType => _lockingMechanismType;
  String get fuelAndIlluminant => _fuelAndIlluminant;
  String get airInflowDesign => _airInflowDesign;
  String get physicalProportions => _physicalProportions;
  PreservationStatus get preservationStatus => _preservationStatus;
  String get accompanyingGear => _accompanyingGear;
  String get inspectorAndCollieryStamps => _inspectorAndCollieryStamps;
  String get historicalContext => _historicalContext;
  String get archivalNotes => _archivalNotes;
  String get photoPath => _photoPath;
  List<String> get tags => _tags;
  DateTime get dateAdded => _dateAdded;

  // Setters
  set cabinetControlNumber(String v) { _cabinetControlNumber = v; notifyListeners(); }
  set apparatusClassification(ApparatusClassification v) { _apparatusClassification = v; notifyListeners(); }
  set foundryOrManufacturer(String v) { _foundryOrManufacturer = v; notifyListeners(); }
  set eraOfProduction(String v) { _eraOfProduction = v; notifyListeners(); }
  set rateDetectionClass(RateDetectionClass v) { _rateDetectionClass = v; notifyListeners(); }
  set bodyMetal(BodyMetal v) { _bodyMetal = v; notifyListeners(); }
  set gauzeConfiguration(String v) { _gauzeConfiguration = v; notifyListeners(); }
  set lockingMechanismType(LockingMechanism v) { _lockingMechanismType = v; notifyListeners(); }
  set fuelAndIlluminant(String v) { _fuelAndIlluminant = v; notifyListeners(); }
  set airInflowDesign(String v) { _airInflowDesign = v; notifyListeners(); }
  set physicalProportions(String v) { _physicalProportions = v; notifyListeners(); }
  set preservationStatus(PreservationStatus v) { _preservationStatus = v; notifyListeners(); }
  set accompanyingGear(String v) { _accompanyingGear = v; notifyListeners(); }
  set inspectorAndCollieryStamps(String v) { _inspectorAndCollieryStamps = v; notifyListeners(); }
  set historicalContext(String v) { _historicalContext = v; notifyListeners(); }
  set archivalNotes(String v) { _archivalNotes = v; notifyListeners(); }
  set photoPath(String v) { _photoPath = v; notifyListeners(); }
  set tags(List<String> v) { _tags = v; notifyListeners(); }
  set dateAdded(DateTime v) { _dateAdded = v; notifyListeners(); }

  void clearAll() {
    _cabinetControlNumber = '';
    _apparatusClassification = ApparatusClassification.englishLever;
    _foundryOrManufacturer = '';
    _eraOfProduction = '';
    _rateDetectionClass = RateDetectionClass.pocketWatch;
    _bodyMetal = BodyMetal.syntheticRuby;
    _gauzeConfiguration = '';
    _lockingMechanismType = LockingMechanism.detachedImpulse;
    _fuelAndIlluminant = '';
    _airInflowDesign = '';
    _physicalProportions = '';
    _preservationStatus = PreservationStatus.unknown;
    _accompanyingGear = '';
    _inspectorAndCollieryStamps = '';
    _historicalContext = '';
    _archivalNotes = '';
    _photoPath = '';
    _tags = [];
    _dateAdded = DateTime.now();
    notifyListeners();
  }
}

final inputProvider = ChangeNotifierProvider<InputNotifier>(
  (ref) => InputNotifier(),
);
