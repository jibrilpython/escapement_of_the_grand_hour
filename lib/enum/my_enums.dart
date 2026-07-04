// ─── ESCAPEMENT ARCHITECTURE ──────────────────────────────────────────────────
enum ApparatusClassification {
  vergeFoliot('Verge & Foliot'),
  recoilAnchor('Anchor / Recoil'),
  deadbeatAnchor('Deadbeat Anchor'),
  cylinder('Cylinder Escapement'),
  englishLever('English Lever'),
  detentChronometer('Detent / Chronometer'),
  doubleWheelChronometer('Double-Wheel Chronometer'),
  coAxial('Co-Axial'),
  other('Unclassified Geometry');

  const ApparatusClassification(this.label);
  final String label;
}

// ─── INSTRUMENT TYPE ──────────────────────────────────────────────────────────
enum RateDetectionClass {
  pocketWatch('Pocket Watch Movement'),
  marineChronometer('Marine Chronometer'),
  towerClock('Tower Clock Train'),
  railwayRegulator('Railway Regulator'),
  observatoryClock('Observatory Regulator');

  const RateDetectionClass(this.label);
  final String label;
}

// ─── PALLET METALLURGY & MATERIAL ─────────────────────────────────────────────
enum BodyMetal {
  syntheticRuby('Synthetic Ruby Inserts'),
  polishedFlint('Polished Flint'),
  oilHardenedSteel('Oil-Hardened Carbon Steel'),
  brassSleeves('Brass Sleeves'),
  jeweledSteel('Jeweled Steel Pallets'),
  mixedUnknown('Composite / Unknown');

  const BodyMetal(this.label);
  final String label;
}

// ─── REGULATING ACTION ────────────────────────────────────────────────────────
enum LockingMechanism {
  frictionalRest('Frictional Rest'),
  detachedImpulse('Detached Impulse'),
  deadbeatLock('Deadbeat Lock'),
  recoilDrop('Recoil Drop'),
  freeSpringDetent('Free-Spring Detent');

  const LockingMechanism(this.label);
  final String label;
}

// ─── PRESERVATION SOUNDNESS ───────────────────────────────────────────────────
enum PreservationStatus {
  museumGrade('Museum Grade - Exhibition Ready'),
  fullyOperational('Running - Pivots Bright'),
  serviceable('Serviceable - Minor Wear'),
  displayOnly('Display Only - Static'),
  requiresRestoration('Restoration Required - Pivot Wear'),
  fragmentary('Fragmentary - Missing Jewels'),
  unknown('Indeterminate');

  const PreservationStatus(this.label);
  final String label;
}
