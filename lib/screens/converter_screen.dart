import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:escapement_of_the_grand_hour/utils/const.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  double _toothCount = 15;
  double _amplitude = 270;
  double _targetHz = 2.5;

  double get _vph => _targetHz * 7200;
  double get _beatSeconds => 1 / (_targetHz * 2);
  double get _impulsesPerHour => _toothCount * _targetHz * 3600;
  double get _amplitudeDeviation => ((_amplitude - 270) / 270) * 86400;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              20.w,
              MediaQuery.of(context).padding.top + 24.h,
              20.w,
              18.h,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: kAccentSurface,
                      borderRadius: BorderRadius.circular(kRadiusPill),
                      border: Border.all(color: kAccent.withValues(alpha: 0.18)),
                    ),
                    child: Text(
                      'Beat rate tools',
                      style: GoogleFonts.ibmPlexMono(
                        color: kAccent,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'VPH / Hertz\nConverter',
                    style: GoogleFonts.cormorantGaramond(
                      color: kPrimaryText,
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w700,
                      height: 0.96,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'Convert between vibrations per hour and hertz, and inspect theoretical timing deviation.',
                    style: GoogleFonts.sourceSans3(
                      color: kSecondaryText,
                      fontSize: 14.sp,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 140.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ResultDial(
                  hertz: _targetHz,
                  vph: _vph,
                  beatSeconds: _beatSeconds,
                  deviation: _amplitudeDeviation,
                ),
                SizedBox(height: 22.h),
                _buildSlider(
                  label: 'ESCAPE WHEEL TOOTH COUNT',
                  value: _toothCount,
                  min: 10,
                  max: 45,
                  divisions: 35,
                  display: _toothCount.round().toString(),
                  onChanged: (value) => setState(() => _toothCount = value),
                ),
                _buildSlider(
                  label: 'BALANCE AMPLITUDE',
                  value: _amplitude,
                  min: 120,
                  max: 360,
                  divisions: 48,
                  display: '${_amplitude.round()} deg',
                  onChanged: (value) => setState(() => _amplitude = value),
                ),
                _buildSlider(
                  label: 'TARGET RATE',
                  value: _targetHz,
                  min: 1,
                  max: 10,
                  divisions: 90,
                  display: '${_targetHz.toStringAsFixed(2)} Hz',
                  onChanged: (value) => setState(() => _targetHz = value),
                ),
                SizedBox(height: 8.h),
                _buildSpecCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String display,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline),
        boxShadow: const [kShadowSubtle],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.ibmPlexMono(
                    color: kSecondaryText,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Text(
                display,
                style: GoogleFonts.ibmPlexMono(
                  color: kAccent,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: kAccent,
              inactiveTrackColor: kOutline,
              thumbColor: kAccent,
              overlayColor: kAccent.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: (next) {
                HapticFeedback.selectionClick();
                onChanged(next);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: kAccentSurface,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kAccent.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          _specRow('Theoretical VPH', _vph.toStringAsFixed(0)),
          _specRow('Single beat interval', '${_beatSeconds.toStringAsFixed(4)} s'),
          _specRow('Wheel impulses / hour', _impulsesPerHour.toStringAsFixed(0)),
          _specRow('Amplitude deviation', '${_amplitudeDeviation.toStringAsFixed(1)} s/day'),
        ],
      ),
    );
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.sourceSans3(color: kSecondaryText, fontSize: 13.sp),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.ibmPlexMono(
              color: kPrimaryText,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultDial extends StatelessWidget {
  final double hertz;
  final double vph;
  final double beatSeconds;
  final double deviation;

  const _ResultDial({
    required this.hertz,
    required this.vph,
    required this.beatSeconds,
    required this.deviation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        border: Border.all(color: kOutline),
        boxShadow: const [kShadowFloat],
      ),
      child: Column(
        children: [
          Text(
            '${hertz.toStringAsFixed(2)} Hz',
            style: GoogleFonts.ibmPlexMono(
              color: kAccent,
              fontSize: 38.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${vph.toStringAsFixed(0)} VPH',
            style: GoogleFonts.ibmPlexMono(
              color: kPrimaryText,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _miniMetric('BEAT', '${beatSeconds.toStringAsFixed(3)}s')),
              SizedBox(width: 10.w),
              Expanded(child: _miniMetric('DELTA', '${deviation.toStringAsFixed(1)}s/d')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniMetric(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: kBackground,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 8.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.ibmPlexMono(
              color: kPrimaryText,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
