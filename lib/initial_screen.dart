import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:escapement_of_the_grand_hour/enum/my_enums.dart';
import 'package:escapement_of_the_grand_hour/providers/user_provider.dart';
import 'package:escapement_of_the_grand_hour/utils/const.dart';
import 'package:escapement_of_the_grand_hour/widgets/escapement_motif.dart';
import 'package:google_fonts/google_fonts.dart';

class InitialScreen extends ConsumerStatefulWidget {
  const InitialScreen({super.key});

  @override
  ConsumerState<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends ConsumerState<InitialScreen> {
  bool _completed = false;

  void _completeEntry() {
    if (_completed) return;
    _completed = true;
    HapticFeedback.mediumImpact();
    ref.read(userProvider).setFirstTimeUser(false);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _BenchLinerPainter())),
          Positioned(
            top: -100.h,
            right: -60.w,
            child: Container(
              width: 260.w,
              height: 260.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kAccent.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 120.h,
            left: -40.w,
            child: Container(
              width: 180.w,
              height: 180.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kSecondaryAccent.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            right: 12.w,
            top: MediaQuery.of(context).padding.top + 80.h,
            child: Opacity(
              opacity: 0.1,
              child: EscapementMotif(
                architecture: ApparatusClassification.englishLever,
                width: 140.w,
                height: 140.w,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeroPanel(),
                  const Spacer(),
                  _SlideToEnter(onComplete: _completeEntry),
                  SizedBox(height: 18.h),
                  Text(
                    'Your collection stays on this device.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sourceSans3(
                      color: kSecondaryText.withValues(alpha: 0.8),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroPanel() {
    return Container(
      padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 26.h),
      decoration: BoxDecoration(
        color: kPanelBg.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(kRadiusStandard),
        border: Border.all(color: kOutline),
        boxShadow: const [kShadowSubtle],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: kAccentSurface,
                  borderRadius: BorderRadius.circular(kRadiusSubtle),
                  border: Border.all(color: kAccent.withValues(alpha: 0.2)),
                ),
                padding: EdgeInsets.all(8.w),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.watch_outlined,
                    color: kAccent,
                    size: 22.sp,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Horological Archive',
                      style: GoogleFonts.ibmPlexMono(
                        color: kAccent,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Private cabinet catalog',
                      style: GoogleFonts.sourceSans3(
                        color: kSecondaryText,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          Text(
            'Escapement of\nthe Grand Hour',
            style: GoogleFonts.cormorantGaramond(
              color: kPrimaryText,
              fontSize: 40.sp,
              fontWeight: FontWeight.w700,
              height: 1.05,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Container(
                width: 32.w,
                height: 2,
                color: kAccent.withValues(alpha: 0.45),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Container(
                  height: 1,
                  color: kOutline,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Catalog vintage escapements — verge, lever, deadbeat, and detent mechanisms — with the precision of a watchmaker\'s bench.',
            style: GoogleFonts.sourceSans3(
              color: kSecondaryText,
              fontSize: 15.sp,
              fontWeight: FontWeight.w300,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideToEnter extends StatefulWidget {
  final VoidCallback onComplete;

  const _SlideToEnter({required this.onComplete});

  @override
  State<_SlideToEnter> createState() => _SlideToEnterState();
}

class _SlideToEnterState extends State<_SlideToEnter> {
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    final thumbSize = 58.h;
    final trackHeight = 70.h;

    return LayoutBuilder(
      builder: (context, constraints) {
        final travel = constraints.maxWidth - thumbSize - 4.w;
        final offset = travel * _progress;

        return Container(
          height: trackHeight,
          decoration: BoxDecoration(
            color: kPanelBg.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(kRadiusPill),
            border: Border.all(color: kOutline),
            boxShadow: const [kShadowSubtle],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kRadiusPill),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: _progress.clamp(0.08, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              kAccent.withValues(alpha: 0.14),
                              kAccent.withValues(alpha: 0.06),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    _progress >= 0.98
                        ? 'Opening cabinet\u2026'
                        : 'Slide to open the cabinet',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sourceSans3(
                      color: _progress > 0.35
                          ? kAccent.withValues(alpha: 0.85)
                          : kSecondaryText,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Positioned(
                  left: 4.w + offset,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _progress =
                            (_progress + details.delta.dx / travel)
                                .clamp(0.0, 1.0);
                      });
                      if (_progress >= 0.98) {
                        widget.onComplete();
                      }
                    },
                    onHorizontalDragEnd: (_) {
                      if (_progress < 0.98) {
                        HapticFeedback.lightImpact();
                        setState(() => _progress = 0);
                      }
                    },
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: BoxDecoration(
                        color: kAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: kPanelBg.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: const [kShadowBlue],
                      ),
                      child: Icon(
                        _progress >= 0.98
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        color: kPanelBg,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Fine ruled lines evoking a watchmaker's bench liner — barely visible grid.
class _BenchLinerPainter extends CustomPainter {
  const _BenchLinerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rulePaint = Paint()
      ..color = kOutline.withValues(alpha: 0.55)
      ..strokeWidth = 0.35;

    const ruleSpacing = 14.0;
    for (double y = 0; y < size.height; y += ruleSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rulePaint);
    }

    final columnPaint = Paint()
      ..color = kOutline.withValues(alpha: 0.35)
      ..strokeWidth = 0.35;
    const columnSpacing = 48.0;
    for (double x = 0; x < size.width; x += columnSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), columnPaint);
    }

    final dotPaint = Paint()
      ..color = kAccent.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    for (double x = columnSpacing; x < size.width; x += columnSpacing) {
      for (double y = ruleSpacing; y < size.height; y += ruleSpacing) {
        canvas.drawCircle(Offset(x, y), 0.6, dotPaint);
      }
    }

    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.1,
        colors: [
          Colors.transparent,
          kBackground.withValues(alpha: 0.35),
        ],
        stops: const [0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignette);
  }

  @override
  bool shouldRepaint(covariant _BenchLinerPainter old) => false;
}
