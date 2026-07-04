import 'package:flutter/material.dart';
import 'package:escapement_of_the_grand_hour/enum/my_enums.dart';

// ─── COLOR PALETTE — "Horological Cabinet" ───────────────────────────────────
const Color kBackground      = Color(0xFFF9F8F6); // movement white
const Color kPrimaryText     = Color(0xFF111010); // pivot black
const Color kPanelBg         = Color(0xFFFFFFFF); // cabinet card surface
const Color kSecondaryText   = Color(0xFF858480); // jewel grey
const Color kAccent          = Color(0xFF2C5F8A); // blued steel
const Color kSecondaryAccent = Color(0xFF9C7B3A); // gilt movement gold
const Color kOutline         = Color(0xFFE8E7E4); // movement plate rule
const Color kError           = Color(0xFFB03A2E); // critical red

// ─── DERIVED COLORS ──────────────────────────────────────────────────────────
const Color kAccentSurface   = Color(0x1A2C5F8A); // blued steel tint
const Color kDangerSurface   = Color(0x1AB03A2E);
const Color kGlassBackground = Color(0xBFFFFFFF);

Color getRateDetectionColor(RateDetectionClass gdc) {
  switch (gdc) {
    case RateDetectionClass.pocketWatch:
      return kAccent;
    case RateDetectionClass.marineChronometer:
      return const Color(0xFF174A6D);
    case RateDetectionClass.towerClock:
      return kSecondaryAccent;
    case RateDetectionClass.railwayRegulator:
      return const Color(0xFF5E6A72);
    case RateDetectionClass.observatoryClock:
      return const Color(0xFF5B4F8F);
  }
}

// ─── PALLET MATERIAL COLORS ───────────────────────────────────────────────────────
Color getBodyMetalColor(BodyMetal bm) {
  switch (bm) {
    case BodyMetal.syntheticRuby:
      return const Color(0xFFB03A2E);
    case BodyMetal.polishedFlint:
      return const Color(0xFF8BA7B7);
    case BodyMetal.oilHardenedSteel:
      return kAccent;
    case BodyMetal.brassSleeves:
      return kSecondaryAccent;
    case BodyMetal.jeweledSteel:
      return const Color(0xFF4C7FA4);
    case BodyMetal.mixedUnknown:
      return kSecondaryText;
  }
}

// ─── PRESERVATION SOUNDNESS COLORS ──────────────────────────────────────────────
Color getConditionColor(PreservationStatus status) {
  switch (status) {
    case PreservationStatus.museumGrade:
      return kAccent;
    case PreservationStatus.fullyOperational:
      return const Color(0xFF22C55E);
    case PreservationStatus.serviceable:
      return const Color(0xFF0891B2);
    case PreservationStatus.displayOnly:
      return kSecondaryText;
    case PreservationStatus.requiresRestoration:
      return kSecondaryAccent;
    case PreservationStatus.fragmentary:
      return kError;
    case PreservationStatus.unknown:
      return kSecondaryText;
  }
}

bool isHazardMechanism(PreservationStatus status, RateDetectionClass gdc) {
  return status == PreservationStatus.fragmentary ||
      status == PreservationStatus.requiresRestoration;
}

double getRateIntensity(RateDetectionClass gdc) {
  switch (gdc) {
    case RateDetectionClass.marineChronometer: return 1.0;
    case RateDetectionClass.observatoryClock: return 0.8;
    case RateDetectionClass.railwayRegulator: return 0.6;
    case RateDetectionClass.towerClock: return 0.45;
    case RateDetectionClass.pocketWatch: return 0.25;
  }
}

// ─── SPACING ─────────────────────────────────────────────────────────────────
const double kSpacingXXS  = 4.0;
const double kSpacingXS   = 8.0;
const double kSpacingS    = 12.0;
const double kSpacingM    = 16.0;
const double kSpacingL    = 20.0;
const double kSpacingXL   = 24.0;
const double kSpacingXXL  = 32.0;
const double kSpacingXXXL = 48.0;

// ─── BORDER RADIUS ───────────────────────────────────────────────────────────
const double kRadiusZero     = 0.0;
const double kRadiusSubtle   = 8.0;
const double kRadiusStandard = 12.0;
const double kRadiusMedium   = 18.0;
const double kRadiusLarge    = 24.0;
const double kRadiusPill     = 999.0;

// ─── SHADOWS ─────────────────────────────────────────────────────────────────
const BoxShadow kShadowSubtle = BoxShadow(
  offset: Offset(0, 4),
  blurRadius: 16,
  spreadRadius: -2,
  color: Color(0x1A000000),
);

const BoxShadow kShadowFloat = BoxShadow(
  offset: Offset(0, 8),
  blurRadius: 28,
  spreadRadius: -4,
  color: Color(0x252C5F8A),
);

const BoxShadow kShadowBlue = BoxShadow(
  offset: Offset(0, 8),
  blurRadius: 24,
  spreadRadius: -2,
  color: Color(0x302C5F8A),
);

const BoxShadow kShadowDanger = BoxShadow(
  offset: Offset(0, 4),
  blurRadius: 16,
  spreadRadius: -2,
  color: Color(0x40B03A2E),
);

// Stroke weights
const double kStrokeWeight       = 1.0;
const double kStrokeWeightMedium = 2.0;
const double kStrokeWeightThick  = 3.0;
