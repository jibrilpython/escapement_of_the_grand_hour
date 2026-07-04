import 'package:escapement_of_the_grand_hour/enum/my_enums.dart';

class HorologicalMechanismModel {
  String id;
  String chronoMatrixIndex;
  ApparatusClassification escapementArchitecture;
  String artisanHallmark;
  String eraOfProduction;
  RateDetectionClass instrumentType;
  BodyMetal palletMetallurgy;
  String liftAngleMetrics;
  LockingMechanism regulatingAction;
  String designFrequencyProfile;
  String escapeWheelToothCount;
  String physicalProportions;
  PreservationStatus preservationSoundness;
  String temperatureRange;
  String calibratedFacility;
  String horologicalGroundZero;
  String archivalNotes;
  String photoPath;
  List<String> tags;
  DateTime dateAdded;

  HorologicalMechanismModel({
    required this.id,
    required this.chronoMatrixIndex,
    required this.escapementArchitecture,
    required this.artisanHallmark,
    required this.eraOfProduction,
    required this.instrumentType,
    required this.palletMetallurgy,
    required this.liftAngleMetrics,
    required this.regulatingAction,
    required this.designFrequencyProfile,
    required this.escapeWheelToothCount,
    required this.physicalProportions,
    required this.preservationSoundness,
    required this.temperatureRange,
    required this.calibratedFacility,
    required this.horologicalGroundZero,
    required this.archivalNotes,
    required this.photoPath,
    required this.tags,
    required this.dateAdded,
  });

  // Compatibility accessors keep the template screens wired while the domain
  // model uses horological names.
  String get cabinetControlNumber => chronoMatrixIndex;
  set cabinetControlNumber(String value) => chronoMatrixIndex = value;
  ApparatusClassification get apparatusClassification => escapementArchitecture;
  set apparatusClassification(ApparatusClassification value) =>
      escapementArchitecture = value;
  String get foundryOrManufacturer => artisanHallmark;
  set foundryOrManufacturer(String value) => artisanHallmark = value;
  RateDetectionClass get rateDetectionClass => instrumentType;
  set rateDetectionClass(RateDetectionClass value) => instrumentType = value;
  BodyMetal get bodyMetal => palletMetallurgy;
  set bodyMetal(BodyMetal value) => palletMetallurgy = value;
  String get gauzeConfiguration => liftAngleMetrics;
  set gauzeConfiguration(String value) => liftAngleMetrics = value;
  LockingMechanism get lockingMechanismType => regulatingAction;
  set lockingMechanismType(LockingMechanism value) => regulatingAction = value;
  String get fuelAndIlluminant => designFrequencyProfile;
  set fuelAndIlluminant(String value) => designFrequencyProfile = value;
  String get airInflowDesign => escapeWheelToothCount;
  set airInflowDesign(String value) => escapeWheelToothCount = value;
  PreservationStatus get preservationStatus => preservationSoundness;
  set preservationStatus(PreservationStatus value) => preservationSoundness = value;
  String get accompanyingGear => temperatureRange;
  set accompanyingGear(String value) => temperatureRange = value;
  String get inspectorAndCollieryStamps => calibratedFacility;
  set inspectorAndCollieryStamps(String value) => calibratedFacility = value;
  String get historicalContext => horologicalGroundZero;
  set historicalContext(String value) => horologicalGroundZero = value;

  Map<String, dynamic> toJson() => {
        'id': id,
        'chronoMatrixIndex': chronoMatrixIndex,
        'escapementArchitecture': escapementArchitecture.name,
        'artisanHallmark': artisanHallmark,
        'eraOfProduction': eraOfProduction,
        'instrumentType': instrumentType.name,
        'palletMetallurgy': palletMetallurgy.name,
        'liftAngleMetrics': liftAngleMetrics,
        'regulatingAction': regulatingAction.name,
        'designFrequencyProfile': designFrequencyProfile,
        'escapeWheelToothCount': escapeWheelToothCount,
        'physicalProportions': physicalProportions,
        'preservationSoundness': preservationSoundness.name,
        'temperatureRange': temperatureRange,
        'calibratedFacility': calibratedFacility,
        'horologicalGroundZero': horologicalGroundZero,
        'archivalNotes': archivalNotes,
        'photoPath': photoPath,
        'tags': tags,
        'dateAdded': dateAdded.toIso8601String(),
      };

  factory HorologicalMechanismModel.fromJson(Map<String, dynamic> json) =>
      HorologicalMechanismModel(
        id: json['id'] ?? '',
        chronoMatrixIndex: json['chronoMatrixIndex'] ?? json['cabinetControlNumber'] ?? '',
        escapementArchitecture:
            ApparatusClassification.values
                .asNameMap()[json['escapementArchitecture'] ?? json['apparatusClassification']] ??
            ApparatusClassification.other,
        artisanHallmark: json['artisanHallmark'] ?? json['foundryOrManufacturer'] ?? '',
        eraOfProduction: json['eraOfProduction'] ?? '',
        instrumentType:
            RateDetectionClass.values
                .asNameMap()[json['instrumentType'] ?? json['rateDetectionClass']] ??
            RateDetectionClass.pocketWatch,
        palletMetallurgy:
            BodyMetal.values.asNameMap()[json['palletMetallurgy'] ?? json['bodyMetal']] ??
            BodyMetal.syntheticRuby,
        liftAngleMetrics: json['liftAngleMetrics'] ?? json['gauzeConfiguration'] ?? '',
        regulatingAction:
            LockingMechanism.values
                .asNameMap()[json['regulatingAction'] ?? json['lockingMechanismType']] ??
            LockingMechanism.detachedImpulse,
        designFrequencyProfile:
            json['designFrequencyProfile'] ?? json['fuelAndIlluminant'] ?? '',
        escapeWheelToothCount:
            json['escapeWheelToothCount'] ?? json['airInflowDesign'] ?? '',
        physicalProportions: json['physicalProportions'] ?? '',
        preservationSoundness:
            PreservationStatus.values
                .asNameMap()[json['preservationSoundness'] ?? json['preservationStatus']] ??
            PreservationStatus.unknown,
        temperatureRange: json['temperatureRange'] ?? json['accompanyingGear'] ?? '',
        calibratedFacility:
            json['calibratedFacility'] ?? json['inspectorAndCollieryStamps'] ?? '',
        horologicalGroundZero:
            json['horologicalGroundZero'] ?? json['historicalContext'] ?? '',
        archivalNotes: json['archivalNotes'] ?? '',
        photoPath: json['photoPath'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        dateAdded:
            DateTime.tryParse(json['dateAdded'] ?? '') ?? DateTime.now(),
      );
}

typedef SafetyMechanismModel = HorologicalMechanismModel;
