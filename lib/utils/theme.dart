import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:escapement_of_the_grand_hour/utils/const.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: kAccent,
    scaffoldBackgroundColor: kBackground,
    colorScheme: const ColorScheme.light(
      primary: kAccent,
      secondary: kSecondaryAccent,
      surface: kPanelBg,
      onSurface: kPrimaryText,
      onPrimary: kBackground,
      error: kError,
      outline: kOutline,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: GoogleFonts.ibmPlexMono(
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        color: kAccent,
        letterSpacing: 1.5,
      ),
      iconTheme: const IconThemeData(color: kPrimaryText),
    ),
    textTheme: TextTheme(
      // ── Display — Cormorant (large sizes only) ─────────────────────────
      displayLarge: GoogleFonts.cormorantGaramond(
        fontSize: 56.sp,
        fontWeight: FontWeight.w700,
        color: kPrimaryText,
        height: 1.0,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.cormorantGaramond(
        fontSize: 44.sp,
        fontWeight: FontWeight.w700,
        color: kPrimaryText,
        height: 1.0,
      ),
      displaySmall: GoogleFonts.cormorantGaramond(
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        color: kPrimaryText,
      ),
      // ── Headlines — Cormorant ───────────────────────────────────────────
      headlineLarge: GoogleFonts.cormorantGaramond(
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        color: kPrimaryText,
        letterSpacing: 0.3,
      ),
      headlineMedium: GoogleFonts.cormorantGaramond(
        fontSize: 26.sp,
        fontWeight: FontWeight.w700,
        color: kPrimaryText,
      ),
      headlineSmall: GoogleFonts.cormorantGaramond(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        color: kPrimaryText,
      ),
      // ── Body — Source Sans 3 ────────────────────────────────────────────
      bodyLarge: GoogleFonts.sourceSans3(
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
        color: kPrimaryText,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.sourceSans3(
        fontSize: 14.sp,
        fontWeight: FontWeight.w300,
        color: kPrimaryText,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.sourceSans3(
        fontSize: 12.sp,
        fontWeight: FontWeight.w300,
        color: kSecondaryText,
      ),
      // ── Labels — IBM Plex Mono ────────────────────────────────────────────
      labelLarge: GoogleFonts.ibmPlexMono(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: kPrimaryText,
        letterSpacing: 0.3,
      ),
      labelMedium: GoogleFonts.ibmPlexMono(
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
        color: kSecondaryText,
        letterSpacing: 0.3,
      ),
      labelSmall: GoogleFonts.ibmPlexMono(
        fontSize: 10.sp,
        fontWeight: FontWeight.w400,
        color: kSecondaryText,
        letterSpacing: 0.5,
      ),
      // ── Titles — Source Sans 3 ──────────────────────────────────────────
      titleLarge: GoogleFonts.sourceSans3(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: kPrimaryText,
      ),
      titleMedium: GoogleFonts.sourceSans3(
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: kPrimaryText,
      ),
      titleSmall: GoogleFonts.sourceSans3(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: kSecondaryText,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kPanelBg,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        borderSide: const BorderSide(color: kOutline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        borderSide: const BorderSide(color: kOutline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        borderSide: const BorderSide(color: kAccent, width: 1.5),
      ),
      hintStyle: GoogleFonts.sourceSans3(
        color: kSecondaryText.withValues(alpha: 0.5),
        fontSize: 14.sp,
        fontWeight: FontWeight.w300,
      ),
      labelStyle: GoogleFonts.sourceSans3(
        color: kSecondaryText,
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
      ),
      floatingLabelStyle: GoogleFonts.sourceSans3(
        color: kAccent,
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAccent,
        foregroundColor: kBackground,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 32.w),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(kRadiusSubtle)),
        ),
        textStyle: GoogleFonts.ibmPlexMono(
          fontWeight: FontWeight.w700,
          fontSize: 12.sp,
          letterSpacing: 1.0,
        ),
      ),
    ),
    cardTheme: const CardThemeData(
      color: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: kOutline,
      thickness: 1.0,
      space: 0,
    ),
    useMaterial3: true,
  );
}
