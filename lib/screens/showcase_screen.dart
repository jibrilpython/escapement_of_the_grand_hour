import 'dart:io';
import 'dart:math' as math;

import 'package:escapement_of_the_grand_hour/enum/my_enums.dart';
import 'package:escapement_of_the_grand_hour/models/project_model.dart';
import 'package:escapement_of_the_grand_hour/providers/image_provider.dart';
import 'package:escapement_of_the_grand_hour/providers/project_provider.dart';
import 'package:escapement_of_the_grand_hour/utils/const.dart';
import 'package:escapement_of_the_grand_hour/widgets/escapement_motif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _brass = Color(0xFFD4AF37);
const Color _steel = Color(0xFF2A3A4A);
const Color _ruby = Color(0xFF9B111E);
const Color _nickel = Color(0xFFE6E8FA);

/// Master Geartrain: swipe down to wind the mainspring, tap a regulating node
/// to hack the train, and drag a node into the acoustic pickup for inspection.
class ShowcaseScreen extends ConsumerStatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  ConsumerState<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends ConsumerState<ShowcaseScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  final Map<String, Offset> _positions = {};
  final Map<String, Offset> _homePositions = {};
  final Set<String> _decoupledIds = {};
  int _layoutHash = -1;
  Size _lastSize = Size.zero;

  double _phase = 0;
  double _torque = 0.38;
  double _trainTravel = 0;
  int _ratchetBucket = 0;
  String? _activeEntryId;
  String? _hackedEntryId;
  String? _timegrapherEntryId;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    final entries = ref.read(projectProvider).entries;
    _normalizeInteractionState(entries);
    if (entries.isEmpty) {
      if (mounted) setState(() {});
      return;
    }

    final active = _activeEntry(entries);
    final hacked = _entryIndex(_hackedEntryId, entries) != null ||
        _entryIndex(_timegrapherEntryId, entries) != null;
    final hz = active == null ? 2.5 : _beatHz(active);
    final smooth = hz >= 4.5;
    final release = hacked ? 0.0 : (0.0015 + hz * 0.00035) * _torque;

    if (!hacked) {
      _phase += smooth ? hz / 210 : hz / 120;
      _trainTravel -= release * 260;
      _torque = (_torque - release).clamp(0.0, 1.0);
    }

    if (mounted) setState(() {});
  }

  SafetyMechanismModel? _activeEntry(List<SafetyMechanismModel> entries) {
    if (entries.isEmpty) return null;
    final index = _entryIndex(_activeEntryId, entries);
    if (index != null) return entries[index];
    return entries.first;
  }

  int? _entryIndex(String? entryId, List<SafetyMechanismModel> entries) {
    if (entryId == null) return null;
    final index = entries.indexWhere((entry) => entry.id == entryId);
    return index >= 0 ? index : null;
  }

  void _normalizeInteractionState(List<SafetyMechanismModel> entries) {
    if (entries.isEmpty) {
      _activeEntryId = null;
      _hackedEntryId = null;
      _timegrapherEntryId = null;
      _decoupledIds.clear();
      return;
    }

    if (_entryIndex(_activeEntryId, entries) == null) {
      _activeEntryId = entries.last.id;
    }
    if (_entryIndex(_hackedEntryId, entries) == null) {
      _hackedEntryId = null;
    }
    if (_entryIndex(_timegrapherEntryId, entries) == null) {
      _timegrapherEntryId = null;
    }
  }

  double _beatHz(SafetyMechanismModel entry) {
    final text = entry.designFrequencyProfile.toLowerCase().replaceAll(',', '');
    final hzMatch = RegExp(r'(\d+(?:\.\d+)?)\s*hz').firstMatch(text);
    if (hzMatch != null) return double.parse(hzMatch.group(1)!);
    final vphMatch = RegExp(r'(\d{3,6})\s*vph').firstMatch(text);
    if (vphMatch != null) return double.parse(vphMatch.group(1)!) / 7200;

    switch (entry.instrumentType) {
      case RateDetectionClass.pocketWatch:
        return 2.5;
      case RateDetectionClass.marineChronometer:
        return 5.0;
      case RateDetectionClass.towerClock:
        return 0.5;
      case RateDetectionClass.railwayRegulator:
        return 3.0;
      case RateDetectionClass.observatoryClock:
        return 4.0;
    }
  }

  int _vph(SafetyMechanismModel entry) => (_beatHz(entry) * 7200).round();

  void _ensureLayout(List<SafetyMechanismModel> entries, Size size) {
    final hash = Object.hash(
      ref.read(projectProvider).stateVersion,
      entries.length,
      size.width.round(),
      size.height.round(),
    );
    if (hash == _layoutHash && size == _lastSize) return;
    _layoutHash = hash;
    _lastSize = size;

    final center = Offset(size.width / 2, size.height * 0.48);
    final radius = math.min(size.width, size.height) * 0.31;
    final rand = math.Random(91);

    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      if (_positions.containsKey(entry.id)) continue;
      final angle = -math.pi / 2 +
          (entry.escapementArchitecture.index / ApparatusClassification.values.length) *
              math.pi *
              2 +
          (rand.nextDouble() - 0.5) * 0.28;
      final orbit = radius * (0.74 + (i % 3) * 0.12);
      _positions[entry.id] = _clampOrbit(
        center + Offset(math.cos(angle) * orbit, math.sin(angle) * orbit),
        size,
      );
      _homePositions[entry.id] = _positions[entry.id]!;
    }

    final ids = entries.map((e) => e.id).toSet();
    _positions.removeWhere((id, _) => !ids.contains(id));
    _homePositions.removeWhere((id, _) => !ids.contains(id));
  }

  static const double _pickupSlotRadius = 36;

  Offset _pickupCenter(Size size, double bottomInset) {
    return Offset(
      size.width / 2,
      size.height - bottomInset - 54.h,
    );
  }

  bool _isOnPickup(Offset pos, Size size, double bottomInset) {
    return (pos - _pickupCenter(size, bottomInset)).distance <= _pickupSlotRadius + 8;
  }

  void _restoreNodeHome(SafetyMechanismModel entry) {
    final home = _homePositions[entry.id];
    if (home != null) _positions[entry.id] = home;
    _decoupledIds.remove(entry.id);
  }

  void _exitTimegrapher(List<SafetyMechanismModel> entries) {
    final index = _entryIndex(_timegrapherEntryId, entries);
    if (index != null) {
      _restoreNodeHome(entries[index]);
    }
    setState(() => _timegrapherEntryId = null);
  }

  Offset _clampOrbit(Offset p, Size size) {
    const sidePad = 58.0;
    return Offset(
      p.dx.clamp(sidePad, size.width - sidePad).toDouble(),
      p.dy.clamp(146.0, size.height - 220.0).toDouble(),
    );
  }

  Offset _clampDrag(Offset p, Size size, double bottomInset) {
    const sidePad = 58.0;
    return Offset(
      p.dx.clamp(sidePad, size.width - sidePad).toDouble(),
      p.dy.clamp(146.0, size.height - bottomInset - 20.h).toDouble(),
    );
  }

  bool _nearPickup(Offset pos, Size size, double bottomInset) {
    return (pos - _pickupCenter(size, bottomInset)).distance <= _pickupSlotRadius + 70;
  }

  void _wind(DragUpdateDetails details) {
    if (details.delta.dy <= 0) return;
    final next = (_torque + details.delta.dy * 0.006).clamp(0.0, 1.0);
    final bucket = (next * 12).floor();
    if (bucket > _ratchetBucket) HapticFeedback.selectionClick();
    setState(() {
      _torque = next;
      _ratchetBucket = bucket;
    });
  }

  void _toggleHack(SafetyMechanismModel entry) {
    HapticFeedback.heavyImpact();
    setState(() {
      _activeEntryId = entry.id;
      _hackedEntryId = _hackedEntryId == entry.id ? null : entry.id;
      _timegrapherEntryId = null;
    });
  }

  void _moveNode(SafetyMechanismModel entry, Offset delta, Size size, double bottomInset) {
    setState(() {
      _decoupledIds.add(entry.id);
      var next =
          (_positions[entry.id] ?? Offset(size.width / 2, size.height / 2)) + delta;
      if (_nearPickup(next, size, bottomInset)) {
        next = _pickupCenter(size, bottomInset);
      }
      _positions[entry.id] = _clampDrag(next, size, bottomInset);
    });
  }

  void _dropNode(SafetyMechanismModel entry, int index, Size size, double bottomInset) {
    var pos = _positions[entry.id] ?? Offset.zero;
    if (_nearPickup(pos, size, bottomInset)) {
      pos = _pickupCenter(size, bottomInset);
    }
    final seated = _isOnPickup(pos, size, bottomInset);
    setState(() {
      _activeEntryId = entry.id;
      if (seated) {
        HapticFeedback.heavyImpact();
        _positions[entry.id] = _pickupCenter(size, bottomInset);
        _timegrapherEntryId = entry.id;
        _hackedEntryId = null;
        _decoupledIds.remove(entry.id);
      } else {
        _decoupledIds.remove(entry.id);
        HapticFeedback.mediumImpact();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;
    final bottomInset = 68.h + 16.h + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: kBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          _normalizeInteractionState(entries);
          _ensureLayout(entries, size);
          final isEmpty = entries.isEmpty;
          final active = _activeEntry(entries);
          final timegrapherIndex = _entryIndex(_timegrapherEntryId, entries);
          final showTimegrapher = timegrapherIndex != null;
          final showHacked = _entryIndex(_hackedEntryId, entries) != null;
          final activeIndex = _entryIndex(_activeEntryId, entries);
          final pickupCenter = _pickupCenter(size, bottomInset);
          var pickupHighlighted = false;
          if (!showTimegrapher) {
            for (final entry in entries) {
              if (!_decoupledIds.contains(entry.id)) continue;
              final pos = _positions[entry.id];
              if (pos != null && _nearPickup(pos, size, bottomInset)) {
                pickupHighlighted = true;
                break;
              }
            }
          }

          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragUpdate: isEmpty ? null : _wind,
                  child: CustomPaint(
                    painter: showTimegrapher
                        ? _TimegrapherPainter(
                            beat: _phase,
                            entry: entries[timegrapherIndex],
                            hz: _beatHz(entries[timegrapherIndex]),
                          )
                        : _GeartrainPainter(
                            phase: _phase,
                            torque: _torque,
                            travel: isEmpty ? 0 : _trainTravel,
                            hacked: showHacked,
                            showMechanism: !isEmpty,
                            nodePositions: [
                              for (final entry in entries)
                                _positions[entry.id] ?? Offset.zero,
                            ],
                            activeIndex: activeIndex,
                            decoupled: [
                              for (final entry in entries) _decoupledIds.contains(entry.id),
                            ],
                          ),
                  ),
                ),
              ),
              _Header(
                active: active,
                torque: _torque,
                hacked: showHacked,
                vph: active == null ? null : _vph(active),
                timegrapher: showTimegrapher,
                empty: isEmpty,
              ),
              if (!showTimegrapher && entries.isNotEmpty)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 94.h,
                  left: 18.w,
                  right: 18.w,
                  child: const IgnorePointer(
                    child: _Hint(
                      text:
                          'Swipe down to wind · tap node to hack · drag node to pickup',
                    ),
                  ),
                ),
              if (!showTimegrapher && entries.isNotEmpty)
                _Pickup(
                  center: pickupCenter,
                  radius: _pickupSlotRadius,
                  highlighted: pickupHighlighted,
                ),
              if (isEmpty)
                Positioned.fill(
                  child: _EmptyState(bottomInset: bottomInset),
                )
              else if (!showTimegrapher)
                ...entries.asMap().entries.map((item) {
                  final index = item.key;
                  final entry = item.value;
                  return _RegulatorNode(
                    key: ValueKey(entry.id),
                    entry: entry,
                    index: index,
                    position: _positions[entry.id] ?? Offset.zero,
                    active: entry.id == _activeEntryId,
                    hacked: entry.id == _hackedEntryId,
                    decoupled: _decoupledIds.contains(entry.id),
                    phase: _phase,
                    onTap: () => _toggleHack(entry),
                    onDrag: (delta) => _moveNode(entry, delta, size, bottomInset),
                    onDrop: () => _dropNode(entry, index, size, bottomInset),
                  );
                }),
              if (showTimegrapher)
                _TimegrapherDrawer(
                  entry: entries[timegrapherIndex],
                  index: timegrapherIndex,
                  vph: _vph(entries[timegrapherIndex]),
                  bottomInset: bottomInset,
                  onClose: () => _exitTimegrapher(entries),
                  onOpen: () => Navigator.pushNamed(
                    context,
                    '/info_screen',
                    arguments: {'index': timegrapherIndex},
                  ),
                ),
              if (showTimegrapher)
                Positioned(
                  left: 18.w,
                  right: 18.w,
                  bottom: bottomInset + 10.h,
                  child: const IgnorePointer(
                    child: _Hint(text: 'Acoustic pickup active · amplified tick trace'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final SafetyMechanismModel? active;
  final double torque;
  final bool hacked;
  final int? vph;
  final bool timegrapher;
  final bool empty;

  const _Header({
    required this.active,
    required this.torque,
    required this.hacked,
    required this.vph,
    required this.timegrapher,
    required this.empty,
  });

  @override
  Widget build(BuildContext context) {
    final activeEntry = active;
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12.h,
      left: 18.w,
      right: 18.w,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: (timegrapher ? _steel : kPanelBg).withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(kRadiusStandard),
          border: Border.all(color: timegrapher ? _nickel.withValues(alpha: 0.24) : kAccent.withValues(alpha: 0.38)),
          boxShadow: const [kShadowSubtle],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timegrapher ? 'Timegrapher Pickup' : 'Master Geartrain',
                    style: GoogleFonts.cormorantGaramond(
                      color: timegrapher ? _nickel : kPrimaryText,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    empty
                        ? 'Catalog mechanisms to mesh the train'
                        : activeEntry == null
                            ? 'Wind the regulator canvas'
                            : '${activeEntry.escapementArchitecture.label} · ${vph ?? 0} vph',
                    style: GoogleFonts.sourceSans3(
                      color: timegrapher ? _nickel.withValues(alpha: 0.72) : kSecondaryText,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 70.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    empty
                        ? 'IDLE'
                        : hacked
                            ? 'HACKED'
                            : '${(torque * 100).round()}%',
                    style: GoogleFonts.ibmPlexMono(
                      color: hacked ? _ruby : kAccent,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(kRadiusPill),
                    child: LinearProgressIndicator(
                      value: torque,
                      minHeight: 4.h,
                      color: hacked ? _ruby : kAccent,
                      backgroundColor: timegrapher ? _nickel.withValues(alpha: 0.12) : kOutline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegulatorNode extends ConsumerStatefulWidget {
  final SafetyMechanismModel entry;
  final int index;
  final Offset position;
  final bool active;
  final bool hacked;
  final bool decoupled;
  final double phase;
  final VoidCallback onTap;
  final ValueChanged<Offset> onDrag;
  final VoidCallback onDrop;

  const _RegulatorNode({
    super.key,
    required this.entry,
    required this.index,
    required this.position,
    required this.active,
    required this.hacked,
    required this.decoupled,
    required this.phase,
    required this.onTap,
    required this.onDrag,
    required this.onDrop,
  });

  @override
  ConsumerState<_RegulatorNode> createState() => _RegulatorNodeState();
}

class _RegulatorNodeState extends ConsumerState<_RegulatorNode> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final operational = isOperationalEscapement(widget.entry.preservationSoundness);
    final accent = operational ? kAccent : _brass;
    final size = widget.active || _dragging ? 74.0 : 62.0;
    final spin = widget.decoupled ? widget.phase * math.pi * 8 : widget.phase * math.pi * 2;
    final imagePath = ref.watch(imageProvider).getImagePath(widget.entry.photoPath);
    final hasPhoto = imagePath != null && File(imagePath).existsSync();

    return Positioned(
      left: widget.position.dx - size / 2,
      top: widget.position.dy - size / 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onPanStart: (_) {
          HapticFeedback.mediumImpact();
          setState(() => _dragging = true);
        },
        onPanUpdate: (details) => widget.onDrag(details.delta),
        onPanEnd: (_) {
          setState(() => _dragging = false);
          widget.onDrop();
        },
        onPanCancel: () {
          setState(() => _dragging = false);
          widget.onDrop();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.38, -0.45),
              colors: [
                Colors.white,
                _nickel,
                accent.withValues(alpha: 0.28),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            border: Border.all(
              color: widget.decoupled
                  ? _ruby
                  : widget.hacked
                      ? _ruby
                      : (widget.active ? accent : kOutline),
              width: widget.active || widget.hacked || widget.decoupled ? 3 : 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: (widget.decoupled ? _ruby : accent).withValues(
                  alpha: widget.active || widget.decoupled ? 0.42 : 0.2,
                ),
                blurRadius: widget.active || widget.decoupled ? 26 : 14,
                offset: Offset(0, widget.decoupled ? 12 : 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.decoupled)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DecoupleHaloPainter(phase: widget.phase),
                  ),
                ),
              Transform.rotate(
                angle: spin,
                child: CustomPaint(
                  size: Size(size, size),
                  painter: _NodeGearPainter(color: accent, hacked: widget.hacked),
                ),
              ),
              Container(
                width: size * 0.62,
                height: size * 0.62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPanelBg.withValues(alpha: 0.92),
                  border: Border.all(color: accent.withValues(alpha: 0.36)),
                ),
                clipBehavior: Clip.antiAlias,
                child: hasPhoto
                    ? Image.file(File(imagePath), fit: BoxFit.cover)
                    : Padding(
                        padding: EdgeInsets.all(size * 0.12),
                        child: EscapementMotif(
                          architecture: widget.entry.escapementArchitecture,
                          operational: operational,
                        ),
                      ),
              ),
              if (widget.hacked)
                Icon(Icons.lock_rounded, color: _ruby, size: 18.sp),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecoupleHaloPainter extends CustomPainter {
  final double phase;
  _DecoupleHaloPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = _ruby.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 8; i++) {
      final start = phase * math.pi * 2 + i * math.pi / 4;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width * 0.46),
        start,
        0.16,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DecoupleHaloPainter old) => old.phase != phase;
}

class _NodeGearPainter extends CustomPainter {
  final Color color;
  final bool hacked;

  _NodeGearPainter({required this.color, required this.hacked});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.43;
    final paint = Paint()
      ..color = (hacked ? _ruby : color).withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, r, paint);
    for (var i = 0; i < 14; i++) {
      final a = i / 14 * math.pi * 2;
      final p1 = center + Offset(math.cos(a), math.sin(a)) * r;
      final p2 = center + Offset(math.cos(a), math.sin(a)) * (r + 5);
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NodeGearPainter old) =>
      old.color != color || old.hacked != hacked;
}

class _Pickup extends StatelessWidget {
  final Offset center;
  final double radius;
  final bool highlighted;

  const _Pickup({
    required this.center,
    required this.radius,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    const outerRing = 7.0;
    final outer = radius + outerRing;

    return Positioned(
      left: center.dx - outer,
      top: center.dy - outer,
      child: IgnorePointer(
        child: Container(
          width: outer * 2,
          height: outer * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _steel.withValues(alpha: 0.94),
            border: Border.all(
              color: highlighted ? _brass : _nickel.withValues(alpha: 0.42),
              width: highlighted ? 2.4 : 1.2,
            ),
            boxShadow: const [kShadowFloat],
          ),
          child: Center(
            child: Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(0, -0.25),
                  radius: 0.95,
                  colors: [
                    _steel.withValues(alpha: 0.48),
                    const Color(0xFF1A2530),
                  ],
                ),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.28),
                  width: 1.4,
                ),
              ),
              child: Icon(
                Icons.graphic_eq_rounded,
                color: _nickel.withValues(alpha: 0.72),
                size: 18.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimegrapherDrawer extends ConsumerWidget {
  final SafetyMechanismModel entry;
  final int index;
  final int vph;
  final double bottomInset;
  final VoidCallback onClose;
  final VoidCallback onOpen;

  const _TimegrapherDrawer({
    required this.entry,
    required this.index,
    required this.vph,
    required this.bottomInset,
    required this.onClose,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePath = ref.watch(imageProvider).getImagePath(entry.photoPath);
    final hasPhoto = imagePath != null && File(imagePath).existsSync();
    return Positioned(
      right: 14.w,
      top: MediaQuery.of(context).padding.top + 104.h,
      bottom: bottomInset + 54.h,
      width: 178.w,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: _nickel.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(kRadiusStandard),
          border: Border.all(color: _steel.withValues(alpha: 0.18)),
          boxShadow: const [kShadowFloat],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Acoustic Trace',
                    style: GoogleFonts.ibmPlexMono(
                      color: _steel,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Icon(Icons.close_rounded, size: 18.sp, color: _steel),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(kRadiusSubtle),
              child: SizedBox(
                height: 96.h,
                width: double.infinity,
                child: hasPhoto
                    ? Image.file(File(imagePath), fit: BoxFit.cover)
                    : ColoredBox(
                        color: kPanelBg,
                        child: Padding(
                          padding: EdgeInsets.all(22.w),
                          child: EscapementMotif(
                            architecture: entry.escapementArchitecture,
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              entry.artisanHallmark.isNotEmpty ? entry.artisanHallmark : 'Unknown maker',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cormorantGaramond(
                color: _steel,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                height: 1.05,
              ),
            ),
            SizedBox(height: 8.h),
            _TraceMetric(label: 'VPH', value: vph.toString()),
            _TraceMetric(label: 'Escapement', value: entry.escapementArchitecture.label),
            if (entry.eraOfProduction.isNotEmpty)
              _TraceMetric(label: 'Era', value: entry.eraOfProduction),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onOpen,
                style: FilledButton.styleFrom(
                  backgroundColor: _steel,
                  foregroundColor: _nickel,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kRadiusPill),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TraceMetric extends StatelessWidget {
  final String label;
  final String value;
  const _TraceMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 7.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.ibmPlexMono(
              color: _steel.withValues(alpha: 0.58),
              fontSize: 8.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.sourceSans3(
              color: _steel,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;
  const _Hint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: kPanelBg.withValues(alpha: 0.93),
          borderRadius: BorderRadius.circular(kRadiusPill),
          border: Border.all(color: kOutline),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.sourceSans3(
            color: kSecondaryText,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final double bottomInset;
  const _EmptyState({required this.bottomInset});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBackground.withValues(alpha: 0.72),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
            decoration: BoxDecoration(
              color: kPanelBg.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(kRadiusStandard),
              border: Border.all(color: kAccent.withValues(alpha: 0.24)),
              boxShadow: const [kShadowSubtle],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                EscapementMotif(
                  architecture: ApparatusClassification.englishLever,
                  width: 70.w,
                  height: 70.w,
                  operational: false,
                ),
                SizedBox(height: 18.h),
                Text(
                  'No regulating organs yet.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    color: kPrimaryText,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Catalog mechanisms to mesh the train.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sourceSans3(
                    color: kSecondaryText,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GeartrainPainter extends CustomPainter {
  final double phase;
  final double torque;
  final double travel;
  final bool hacked;
  final bool showMechanism;
  final List<Offset> nodePositions;
  final int? activeIndex;
  final List<bool> decoupled;

  _GeartrainPainter({
    required this.phase,
    required this.torque,
    required this.travel,
    required this.hacked,
    required this.showMechanism,
    required this.nodePositions,
    required this.activeIndex,
    required this.decoupled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _bench(canvas, size);
    if (!showMechanism) return;
    _gearMesh(canvas, size);
    _nodeTraces(canvas, size);
  }

  void _bench(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = kBackground);

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF2F0EB),
            kBackground,
            const Color(0xFFEDEAE4),
          ],
          stops: const [0.0, 0.52, 1.0],
        ).createShader(Offset.zero & size),
    );

    final rulePaint = Paint()
      ..color = kOutline.withValues(alpha: 0.46)
      ..strokeWidth = 0.35;
    const ruleSpacing = 14.0;
    for (double y = 0; y < size.height; y += ruleSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rulePaint);
    }

    final columnPaint = Paint()
      ..color = kOutline.withValues(alpha: 0.30)
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
        canvas.drawCircle(Offset(x, y), 0.55, dotPaint);
      }
    }

    _drawBenchGrain(canvas, size);

    final travelPaint = Paint()
      ..color = kOutline.withValues(alpha: 0.16)
      ..strokeWidth = 0.45;
    final benchOffset = travel % 90;
    for (double y = benchOffset - 90; y < size.height + 90; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), travelPaint);
    }
    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), travelPaint);
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.12),
          radius: 0.9,
          colors: [
            _nickel.withValues(alpha: 0.30),
            _nickel.withValues(alpha: 0.10),
            Colors.transparent,
          ],
          stops: const [0.0, 0.42, 1.0],
        ).createShader(Offset.zero & size),
    );

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.15,
          colors: [
            Colors.transparent,
            kBackground.withValues(alpha: 0.28),
          ],
          stops: const [0.58, 1.0],
        ).createShader(Offset.zero & size),
    );
  }

  void _drawBenchGrain(Canvas canvas, Size size) {
    final speckle = Paint()..color = kPrimaryText.withValues(alpha: 0.022);
    for (var i = 0; i < 360; i++) {
      final x = (i * 127.13 + 311.7) % size.width;
      final y = (i * 269.31 + 47.3) % size.height;
      canvas.drawCircle(Offset(x, y), 0.4 + (i % 3) * 0.18, speckle);
    }

    final fiber = Paint()
      ..color = kSecondaryAccent.withValues(alpha: 0.025)
      ..strokeWidth = 0.6;
    for (var i = 0; i < 18; i++) {
      final y = (i * 97.3 + 22.0) % size.height;
      canvas.drawLine(Offset(-12, y), Offset(size.width + 12, y + 3.5), fiber);
    }
  }

  void _gearMesh(Canvas canvas, Size size) {
    final gears = _gearLayout(size);
    final drive = hacked ? 0.0 : phase * math.pi * 2 * (0.42 + torque * 0.58);
    final driverRadius = gears.first.radius;

    for (var i = 0; i < gears.length; i++) {
      final gear = gears[i];
      final direction = i.isEven ? 1.0 : -1.0;
      _drawGear(
        canvas,
        gear.center,
        gear.radius,
        gear.teeth,
        drive * direction * driverRadius / gear.radius,
      );
    }
  }

  List<({Offset center, double radius, int teeth})> _gearLayout(Size size) {
    const gears = [
      (radius: 39.0, teeth: 28, angle: 0.0),
      (radius: 53.0, teeth: 36, angle: 0.04),
      (radius: 35.0, teeth: 26, angle: -0.52),
      (radius: 48.0, teeth: 34, angle: 1.02),
      (radius: 37.0, teeth: 28, angle: -0.24),
    ];

    final layout = <({Offset center, double radius, int teeth})>[];
    var center = Offset(size.width / 2 - 145, size.height * 0.42);
    var previousRadius = gears.first.radius;
    layout.add((center: center, radius: gears.first.radius, teeth: gears.first.teeth));

    for (var i = 1; i < gears.length; i++) {
      final gear = gears[i];
      final distance = (previousRadius + gear.radius) * 0.99;
      center += Offset(
        math.cos(gear.angle) * distance,
        math.sin(gear.angle) * distance,
      );
      layout.add((center: center, radius: gear.radius, teeth: gear.teeth));
      previousRadius = gear.radius;
    }
    return layout;
  }

  void _drawGear(
    Canvas canvas,
    Offset center,
    double radius,
    int teeth,
    double angle,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Draw non-rotating light/shadow first. If this rotates, the gear appears
    // off-axis even when its geometry is centered.
    canvas.drawOval(
      Rect.fromCircle(center: const Offset(0, 0), radius: radius * 1.03)
          .shift(const Offset(0, 5)),
      Paint()..color = kPrimaryText.withValues(alpha: 0.04),
    );
    canvas.drawCircle(
      Offset.zero,
      radius * 1.08,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.44),
            _nickel.withValues(alpha: 0.22),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius * 1.08)),
    );

    // A centered frosted-nickel under-plate keeps the spinning brass teeth
    // visually seated on the same axis.
    canvas.drawCircle(
      Offset.zero,
      radius * 0.92,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.25, -0.35),
          colors: [
            _nickel.withValues(alpha: 0.20),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius)),
    );

    canvas.rotate(angle);

    final stroke = Paint()
      ..color = _brass.withValues(alpha: 0.62)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final gearBody = _gearPath(radius, teeth);
    canvas.drawPath(
      gearBody,
      Paint()
        ..color = _brass.withValues(alpha: 0.16)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(gearBody, stroke);

    canvas.drawCircle(Offset.zero, radius * 0.68, stroke);
    canvas.drawCircle(Offset.zero, radius * 0.24, stroke);

    final spokePaint = Paint()
      ..color = _brass.withValues(alpha: 0.38)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final a = i / 6 * math.pi * 2;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(dir * radius * 0.28, dir * radius * 0.62, spokePaint);
    }

    // Perlage dots on the plate face.
    for (var i = 0; i < 18; i++) {
      final a = i / 18 * math.pi * 2;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawCircle(
        dir * radius * 0.46,
        1.25,
        Paint()..color = _nickel.withValues(alpha: 0.20),
      );
    }
    canvas.restore();
  }

  Path _gearPath(double radius, int teeth) {
    final path = Path();
    for (var i = 0; i < teeth * 2; i++) {
      final a = i / (teeth * 2) * math.pi * 2;
      final r = i.isEven ? radius * 1.02 : radius * 0.90;
      final point = Offset(math.cos(a) * r, math.sin(a) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  void _nodeTraces(Canvas canvas, Size size) {
    final gears = _gearLayout(size);
    for (var i = 0; i < nodePositions.length; i++) {
      final p = nodePositions[i];
      if (p == Offset.zero) continue;
      final active = activeIndex == i;
      final loose = i < decoupled.length && decoupled[i];
      final gear = gears[i % gears.length];
      final delta = p - gear.center;
      final distance = delta.distance;
      final dir = distance == 0 ? const Offset(1, 0) : delta / distance;
      final pivot = gear.center + dir * (gear.radius * 0.72);
      final end = p - dir * 34;
      final path = Path()
        ..moveTo(pivot.dx, pivot.dy)
        ..quadraticBezierTo(
          (pivot.dx + end.dx) / 2,
          (pivot.dy + end.dy) / 2 - (loose ? 68 : 24),
          end.dx,
          end.dy,
        );
      canvas.drawPath(
        path,
        Paint()
          ..color = (active ? kAccent : _brass)
              .withValues(alpha: loose ? 0.10 : active ? 0.58 : 0.28)
          ..style = PaintingStyle.stroke
          ..strokeWidth = active ? 2.8 : 1.4,
      );
      canvas.drawCircle(
        pivot,
        active ? 4.2 : 2.8,
        Paint()..color = _ruby.withValues(alpha: active ? 0.88 : 0.48),
      );
      if (!loose) {
        final t = (phase + i * 0.13) % 1;
        final dot = _quad(pivot, end, t);
        canvas.drawCircle(
          dot,
          active ? 4 : 2.6,
          Paint()..color = _ruby.withValues(alpha: active ? 0.9 : 0.42),
        );
      }
    }
  }

  Offset _quad(Offset a, Offset b, double t) {
    final c = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2 - 38);
    final u = 1 - t;
    return Offset(
      u * u * a.dx + 2 * u * t * c.dx + t * t * b.dx,
      u * u * a.dy + 2 * u * t * c.dy + t * t * b.dy,
    );
  }

  @override
  bool shouldRepaint(covariant _GeartrainPainter old) =>
      old.phase != phase ||
      old.torque != torque ||
      old.travel != travel ||
      old.hacked != hacked ||
      old.showMechanism != showMechanism ||
      old.nodePositions != nodePositions ||
      old.activeIndex != activeIndex ||
      old.decoupled != decoupled;
}

class _TimegrapherPainter extends CustomPainter {
  final double beat;
  final SafetyMechanismModel entry;
  final double hz;

  _TimegrapherPainter({
    required this.beat,
    required this.entry,
    required this.hz,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _steel);
    final grid = Paint()
      ..color = _nickel.withValues(alpha: 0.12)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final path = Path();
    final mid = size.height * 0.48;
    for (double x = 0; x <= size.width; x += 3) {
      final t = x / size.width;
      final carrier = math.sin((t * hz * 3 + beat * 2) * math.pi * 2);
      final tick = math.pow(math.sin((t * hz * 6 + beat * 2) * math.pi), 18).toDouble();
      final y = mid + carrier * 18 + tick * 54;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = _ruby.withValues(alpha: 0.95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
    canvas.drawLine(
      Offset(0, mid),
      Offset(size.width, mid),
      Paint()
        ..color = _nickel.withValues(alpha: 0.28)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _TimegrapherPainter old) =>
      old.beat != beat || old.entry != entry || old.hz != hz;
}
