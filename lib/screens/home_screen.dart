import 'dart:io';
import 'dart:math' show cos, sin;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:escapement_of_the_grand_hour/enum/my_enums.dart';
import 'package:escapement_of_the_grand_hour/models/project_model.dart';
import 'package:escapement_of_the_grand_hour/providers/image_provider.dart';
import 'package:escapement_of_the_grand_hour/providers/input_provider.dart';
import 'package:escapement_of_the_grand_hour/providers/project_provider.dart';
import 'package:escapement_of_the_grand_hour/providers/search_provider.dart';
import 'package:escapement_of_the_grand_hour/utils/const.dart';
import 'package:escapement_of_the_grand_hour/widgets/escapement_motif.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  ApparatusClassification? _architectureFilter;

  static const _familyFilters = [
    ApparatusClassification.vergeFoliot,
    ApparatusClassification.recoilAnchor,
    ApparatusClassification.deadbeatAnchor,
    ApparatusClassification.englishLever,
    ApparatusClassification.detentChronometer,
    ApparatusClassification.coAxial,
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() => setState(() {}));
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openAdd() {
    HapticFeedback.lightImpact();
    ref.read(inputProvider).clearAll();
    ref.read(imageProvider).clearImage();
    Navigator.pushNamed(context, '/add_screen');
  }

  @override
  Widget build(BuildContext context) {
    final searchProv = ref.watch(searchProvider);
    final allEntries = ref.watch(projectProvider).entries;
    final query = searchProv.searchQuery.toLowerCase();

    final entries = allEntries.where((e) {
      final matchesSearch = query.isEmpty ||
          e.artisanHallmark.toLowerCase().contains(query) ||
          e.chronoMatrixIndex.toLowerCase().contains(query) ||
          e.escapementArchitecture.label.toLowerCase().contains(query) ||
          e.horologicalGroundZero.toLowerCase().contains(query) ||
          e.designFrequencyProfile.toLowerCase().contains(query);
      final matchesFamily = _architectureFilter == null ||
          e.escapementArchitecture == _architectureFilter;
      return matchesSearch && matchesFamily;
    }).toList();

    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final bottomNavTop = bottomSafe + 16.h + 68.h;
    final fabBottomInset = bottomNavTop + 12.h;

    return Scaffold(
      backgroundColor: kBackground,
      resizeToAvoidBottomInset: false,
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(allEntries.length)),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
              child: _buildSearchBar(),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 36.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                physics: const BouncingScrollPhysics(),
                children: [
                  _familyChip(null, 'All families'),
                  ..._familyFilters.map((f) => _familyChip(f, f.label)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 16.h)),
          if (entries.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyState())
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverList.separated(
                itemCount: entries.length,
                separatorBuilder: (_, _) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final mainIndex = allEntries.indexOf(entry);
                  return _buildListCard(entry, mainIndex);
                },
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: fabBottomInset + 64.h)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        tooltip: 'Catalog mechanism',
        backgroundColor: kAccent,
        foregroundColor: kPanelBg,
        elevation: 2,
        highlightElevation: 4,
        shape: const CircleBorder(),
        child: Icon(Icons.add_rounded, size: 28.sp),
      ),
      floatingActionButtonLocation: _FabAboveBottomNavLocation(fabBottomInset),
    );
  }

  Widget _buildHeader(int count) {
    final top = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, top + 16.h, 20.w, 16.h),
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusStandard),
          border: Border.all(color: kAccent.withValues(alpha: 0.38)),
          boxShadow: const [kShadowSubtle],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -8.w,
              top: -8.h,
              child: Opacity(
                opacity: 0.08,
                child: EscapementMotif(
                  architecture: ApparatusClassification.englishLever,
                  width: 88.w,
                  height: 88.w,
                ),
              ),
            ),
            Column(
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
                    'Horological cabinet',
                    style: GoogleFonts.ibmPlexMono(
                      color: kAccent,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Escapement\nCabinet',
                  style: GoogleFonts.cormorantGaramond(
                    color: kPrimaryText,
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.02,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Container(width: 28.w, height: 2, color: kAccent.withValues(alpha: 0.5)),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        count == 1
                            ? '1 mechanism in your collection'
                            : '$count mechanisms in your collection',
                        style: GoogleFonts.sourceSans3(
                          color: kSecondaryText,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final isFocused = _searchFocusNode.hasFocus;
    return Container(
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusPill),
        border: Border.all(
          color: isFocused ? kAccent.withValues(alpha: 0.5) : kOutline,
          width: isFocused ? 1.5 : 1,
        ),
        boxShadow: isFocused ? const [kShadowSubtle] : null,
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (v) => ref.read(searchProvider.notifier).setSearchQuery(v),
        style: GoogleFonts.sourceSans3(color: kPrimaryText, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: 'Search makers, indexes, beat rates…',
          hintStyle: GoogleFonts.sourceSans3(
            color: kSecondaryText.withValues(alpha: 0.65),
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isFocused ? kAccent : kSecondaryText,
            size: 22.sp,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, color: kSecondaryText, size: 20.sp),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(searchProvider.notifier).setSearchQuery('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.transparent,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 14.h),
        ),
      ),
    );
  }

  Widget _familyChip(ApparatusClassification? family, String label) {
    final isSelected = _architectureFilter == family;
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _architectureFilter = family);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? kAccent : kPanelBg,
            borderRadius: BorderRadius.circular(kRadiusPill),
            border: Border.all(
              color: isSelected ? kAccent : kOutline,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.sourceSans3(
              color: isSelected ? kPanelBg : kSecondaryText,
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 48.h),
      child: Column(
        children: [
          SizedBox(
            width: 72.w,
            height: 72.w,
            child: CustomPaint(
              size: Size(72.w, 72.w),
              painter: _EmptyStateIconPainter(),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'No escapements in this cabinet.',
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 11.sp,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 20.h),
          TextButton.icon(
            onPressed: _openAdd,
            icon: Icon(Icons.add_rounded, size: 18.sp, color: kAccent),
            label: Text(
              'Catalog your first mechanism',
              style: GoogleFonts.sourceSans3(
                color: kAccent,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(SafetyMechanismModel entry, int mainIndex) {
    final imageProv = ref.watch(imageProvider);
    final imagePath = imageProv.getImagePath(entry.photoPath);
    final hasPhoto = imagePath != null && File(imagePath).existsSync();
    final operational = isOperationalEscapement(entry.preservationSoundness);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadiusStandard),
        boxShadow: const [kShadowSubtle],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusStandard),
        child: Material(
          color: kPanelBg,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusStandard),
            side: const BorderSide(color: kOutline),
          ),
          child: InkWell(
            onTap: () => Navigator.pushNamed(
              context,
              '/info_screen',
              arguments: {'index': mainIndex},
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4.w,
                    color: operational ? kAccent : kSecondaryAccent,
                  ),
                  SizedBox(
                    width: 72.w,
                    height: 72.w,
                    child: hasPhoto
                        ? Hero(
                            tag: 'grid_img_$mainIndex',
                            child: Image.file(
                              File(imagePath),
                              fit: BoxFit.cover,
                              width: 72.w,
                              height: 72.w,
                            ),
                          )
                        : ColoredBox(
                            color: kAccentSurface,
                            child: Center(
                              child: EscapementMotif(
                                architecture: entry.escapementArchitecture,
                                operational: operational,
                                width: 36.w,
                                height: 36.w,
                              ),
                            ),
                          ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12.w, 10.h, 14.w, 10.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.artisanHallmark.isNotEmpty
                                ? entry.artisanHallmark
                                : 'Unknown maker',
                            style: GoogleFonts.cormorantGaramond(
                              color: kPrimaryText,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            entry.escapementArchitecture.label,
                            style: GoogleFonts.sourceSans3(
                              color: kSecondaryText,
                              fontSize: 12.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6.h),
                          Wrap(
                            spacing: 6.w,
                            runSpacing: 4.h,
                            children: [
                              if (entry.designFrequencyProfile.isNotEmpty)
                                _metaPill(entry.designFrequencyProfile, mono: true),
                              if (entry.eraOfProduction.isNotEmpty)
                                _metaPill(entry.eraOfProduction),
                            ],
                          ),
                          if (entry.chronoMatrixIndex.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              entry.chronoMatrixIndex,
                              style: GoogleFonts.ibmPlexMono(
                                color: kSecondaryText.withValues(alpha: 0.75),
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: kSecondaryText.withValues(alpha: 0.45),
                        size: 22.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _metaPill(String text, {bool mono = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: kBackground,
        borderRadius: BorderRadius.circular(kRadiusPill),
        border: Border.all(color: kOutline),
      ),
      child: Text(
        text,
        style: mono
            ? GoogleFonts.ibmPlexMono(
                color: kAccent,
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
              )
            : GoogleFonts.sourceSans3(
                color: kSecondaryText,
                fontSize: 11.sp,
              ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Positions the FAB above the main nav pill — matches [MainNavigation] layout.
class _FabAboveBottomNavLocation extends FloatingActionButtonLocation {
  final double bottomInset;

  const _FabAboveBottomNavLocation(this.bottomInset);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry geometry) {
    final fabSize = geometry.floatingActionButtonSize;
    final x = geometry.scaffoldSize.width - fabSize.width - 16.w;
    final y = geometry.scaffoldSize.height - fabSize.height - bottomInset;
    return Offset(x, y);
  }
}

class _EmptyStateIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final r = size.width / 2 - 4;

    // ── Outer rim shadow ──
    final rimShadow = Paint()
      ..color = kOutline.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(cx, cx), r + 2, rimShadow);

    // ── Brass plate ──
    final plate = Paint()
      ..shader = RadialGradient(
        colors: [
          kSecondaryAccent.withValues(alpha: 0.18),
          kSecondaryAccent.withValues(alpha: 0.06),
          kBackground,
        ],
        stops: const [0.1, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cx), radius: r));
    canvas.drawCircle(Offset(cx, cx), r, plate);

    // ── Outer rim ──
    final rim = Paint()
      ..color = kOutline.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(cx, cx), r, rim);

    // ── Inner rim highlight ──
    final rimInner = Paint()
      ..color = kPanelBg.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(Offset(cx, cx), r - 3, rimInner);

    // ── Deadbeat anchor escapement ──
    final w = size.width;
    final h = size.height;

    // Glow behind the motif
    final glow = Paint()
      ..color = kAccent.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final glowPath = Path()
      ..moveTo(w * 0.5, h * 0.20)
      ..lineTo(w * 0.34, h * 0.64)
      ..lineTo(w * 0.66, h * 0.64)
      ..close();
    canvas.drawPath(glowPath, glow);

    // Motif fill
    final fill = Paint()
      ..color = kAccent.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    final motifPath = Path()
      ..moveTo(w * 0.5, h * 0.20)
      ..lineTo(w * 0.34, h * 0.64)
      ..lineTo(w * 0.66, h * 0.64)
      ..close();
    canvas.drawPath(motifPath, fill);

    // Motif stroke (thicker bottom stroke for depth)
    final stroke = Paint()
      ..color = kAccent.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(motifPath, stroke);

    // Escape wheel arc
    final wheel = Paint()
      ..color = kAccent.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, h * 0.80), radius: w * 0.20),
      3.4,
      2.0,
      false,
      wheel,
    );

    // Wheel teeth
    final teeth = Paint()
      ..color = kAccent.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (int i = 0; i < 8; i++) {
      final angle = 3.4 + (2.0 / 8) * i;
      final innerR = w * 0.18;
      final outerR = w * 0.22;
      canvas.drawLine(
        Offset(cx + innerR * cos(angle), h * 0.80 + innerR * sin(angle)),
        Offset(cx + outerR * cos(angle), h * 0.80 + outerR * sin(angle)),
        teeth,
      );
    }

    // ── Subtle reflection highlight ──
    final highlight = Paint()
      ..shader = RadialGradient(
        colors: [
          kPanelBg.withValues(alpha: 0.25),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6],
      ).createShader(Rect.fromCircle(center: Offset(cx - r * 0.3, cx - r * 0.3), radius: r * 0.6));
    canvas.drawCircle(Offset(cx - r * 0.3, cx - r * 0.3), r * 0.6, highlight);
  }

  @override
  bool shouldRepaint(covariant _EmptyStateIconPainter old) => false;
}
