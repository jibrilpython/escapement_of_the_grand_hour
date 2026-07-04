import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:escapement_of_the_grand_hour/common/photo_bottom_sheet.dart';
import 'package:escapement_of_the_grand_hour/enum/my_enums.dart';
import 'package:escapement_of_the_grand_hour/providers/image_provider.dart';
import 'package:escapement_of_the_grand_hour/providers/input_provider.dart';
import 'package:escapement_of_the_grand_hour/providers/project_provider.dart';
import 'package:escapement_of_the_grand_hour/utils/const.dart';
import 'package:escapement_of_the_grand_hour/widgets/escapement_motif.dart';
import 'package:google_fonts/google_fonts.dart';

class AddScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final int currentIndex;
  const AddScreen({super.key, this.isEdit = false, this.currentIndex = 0});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageCtrl;
  int _currentPage = 0;
  late AnimationController _shakeCtrl;
  bool _showCabinetError = false;

  late TextEditingController _cabinetCtrl;
  late TextEditingController _foundryCtrl;
  late TextEditingController _eraCtrl;
  late TextEditingController _gauzeCtrl;
  late TextEditingController _fuelCtrl;
  late TextEditingController _airCtrl;
  late TextEditingController _dimCtrl;
  late TextEditingController _gearCtrl;
  late TextEditingController _stampsCtrl;
  late TextEditingController _contextCtrl;
  late TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    final p = ref.read(inputProvider);
    _cabinetCtrl = TextEditingController(text: p.cabinetControlNumber);
    _foundryCtrl = TextEditingController(text: p.foundryOrManufacturer);
    _eraCtrl = TextEditingController(text: p.eraOfProduction);
    _gauzeCtrl = TextEditingController(text: p.gauzeConfiguration);
    _fuelCtrl = TextEditingController(text: p.fuelAndIlluminant);
    _airCtrl = TextEditingController(text: p.airInflowDesign);
    _dimCtrl = TextEditingController(text: p.physicalProportions);
    _gearCtrl = TextEditingController(text: p.accompanyingGear);
    _stampsCtrl = TextEditingController(text: p.inspectorAndCollieryStamps);
    _contextCtrl = TextEditingController(text: p.historicalContext);
    _notesCtrl = TextEditingController(text: p.archivalNotes);
    _cabinetCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _shakeCtrl.dispose();
    for (final c in [
      _cabinetCtrl, _foundryCtrl, _eraCtrl, _gauzeCtrl, _fuelCtrl,
      _airCtrl, _dimCtrl, _gearCtrl, _stampsCtrl, _contextCtrl, _notesCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _goToPage(int page) => _pageCtrl.animateToPage(
    page,
    duration: const Duration(milliseconds: 280),
    curve: Curves.easeInOut,
  );

  void _triggerCabinetError() {
    setState(() => _showCabinetError = true);
    _shakeCtrl.forward(from: 0);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showCabinetError = false);
    });
  }

  void _save() async {
    final p = ref.read(inputProvider);
    p.cabinetControlNumber = _cabinetCtrl.text.trim();
    p.foundryOrManufacturer = _foundryCtrl.text;
    p.eraOfProduction = _eraCtrl.text;
    p.gauzeConfiguration = _gauzeCtrl.text;
    p.fuelAndIlluminant = _fuelCtrl.text;
    p.airInflowDesign = _airCtrl.text;
    p.physicalProportions = _dimCtrl.text;
    p.accompanyingGear = _gearCtrl.text;
    p.inspectorAndCollieryStamps = _stampsCtrl.text;
    p.historicalContext = _contextCtrl.text;
    p.archivalNotes = _notesCtrl.text;

    if (_cabinetCtrl.text.trim().isEmpty) {
      _goToPage(0);
      _triggerCabinetError();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _SavingDialog(),
    );
    await Future.delayed(const Duration(milliseconds: 1100));

    if (widget.isEdit) {
      ref.read(projectProvider).editEntry(ref, widget.currentIndex);
    } else {
      ref.read(projectProvider).addEntry(ref);
    }

    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context);
      ref.read(inputProvider).clearAll();
      ref.read(imageProvider).clearImage();
    }
  }

  static const _stepLabels = ['Registry', 'Specs', 'Archive'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: kPrimaryText, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEdit ? 'Edit mechanism' : 'Catalog mechanism',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: kPrimaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [_buildPage1(), _buildPage2(), _buildPage3()],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(kRadiusPill),
            child: SizedBox(
              height: 4.h,
              child: Row(
                children: List.generate(3, (i) {
                  final filled = i <= _currentPage;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                      color: filled ? kAccent : kOutline,
                    ),
                  );
                }),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: List.generate(3, (i) {
              final isCurrent = i == _currentPage;
              final isComplete = i < _currentPage;
              return Expanded(
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 26.w,
                      height: 26.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrent
                            ? kAccent
                            : isComplete
                                ? kAccent.withValues(alpha: 0.15)
                                : kPanelBg,
                        border: Border.all(
                          color: isCurrent || isComplete
                              ? kAccent
                              : kOutline,
                          width: isCurrent ? 0 : 1,
                        ),
                      ),
                      child: Center(
                        child: isComplete
                            ? Icon(Icons.check_rounded, color: kAccent, size: 14.sp)
                            : Text(
                                '${i + 1}',
                                style: GoogleFonts.ibmPlexMono(
                                  color: isCurrent ? kPanelBg : kSecondaryText,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _stepLabels[i],
                        style: GoogleFonts.sourceSans3(
                          color: isCurrent ? kPrimaryText : kSecondaryText,
                          fontSize: 12.sp,
                          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (i < 2)
                      Container(
                        width: 12.w,
                        height: 1,
                        margin: EdgeInsets.only(right: 8.w),
                        color: kOutline,
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPage1() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader('01', 'Registry'),
          SizedBox(height: 24.h),
          _buildPhotoSection(),
          SizedBox(height: 28.h),
          // Cabinet control number with shake + inline error
          AnimatedBuilder(
            animation: _shakeCtrl,
            builder: (context, child) {
              final shake = _shakeCtrl.isAnimating
                  ? (8.0 * (0.5 - (_shakeCtrl.value - 0.5).abs()) *
                      ((_shakeCtrl.value * 14).floor().isEven ? 1 : -1))
                  : 0.0;
              return Transform.translate(
                offset: Offset(shake, 0),
                child: child,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _monoField(
                  label: 'CABINET CONTROL NUMBER',
                  ctrl: _cabinetCtrl,
                  hint: 'e.g. SLV-WOLF-1912-PA-089',
                  hasError: _showCabinetError,
                  onChanged: (v) {
                    ref.read(inputProvider).cabinetControlNumber = v;
                    if (_showCabinetError && v.trim().isNotEmpty) {
                      setState(() => _showCabinetError = false);
                    }
                  },
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: _showCabinetError
                      ? Container(
                          margin: EdgeInsets.only(top: 6.h, bottom: 12.h),
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: kAccent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(kRadiusSubtle),
                            border: Border.all(
                                color: kAccent.withValues(alpha: 0.4),
                                width: 1.0),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: kAccent, size: 14.sp),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  'A cabinet control number is required before committing this record.',
                                  style: GoogleFonts.sourceSans3(
                                    color: kAccent,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          _buildEnumGroup<ApparatusClassification>(
            label: 'ESCAPEMENT ARCHITECTURE',
            values: ApparatusClassification.values,
            current: ref.watch(inputProvider).apparatusClassification,
            onSelected: (t) => ref.read(inputProvider).apparatusClassification = t,
            labelBuilder: (t) => t.label,
          ),
          _monoField(
            label: 'ARTISAN HALLMARK',
            ctrl: _foundryCtrl,
            hint: 'e.g. Wolf Safety Mechanism Co., Koehler',
            onChanged: (v) => ref.read(inputProvider).foundryOrManufacturer = v,
          ),
          _monoField(
            label: 'ERA OF PRODUCTION',
            ctrl: _eraCtrl,
            hint: 'e.g. 1910s',
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9s]')),
              _EraInputFormatter(),
            ],
            onChanged: (v) => ref.read(inputProvider).eraOfProduction = v,
          ),
          _buildEnumGroup<RateDetectionClass>(
            label: 'INSTRUMENT TYPE CLASS',
            values: RateDetectionClass.values,
            current: ref.watch(inputProvider).rateDetectionClass,
            onSelected: (t) => ref.read(inputProvider).rateDetectionClass = t,
            labelBuilder: (t) => t.label,
          ),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader('02', 'Technical Specs'),
          SizedBox(height: 24.h),
          _monoField(
            label: 'LIFT ANGLE METRICS',
            ctrl: _gauzeCtrl,
            hint: 'e.g. Double gauze, 28 mesh/inch, copper mesh',
            onChanged: (v) => ref.read(inputProvider).gauzeConfiguration = v,
          ),
          _monoField(
            label: 'DESIGN FREQUENCY PROFILE',
            ctrl: _fuelCtrl,
            hint: 'e.g. Naphtha, calcium carbide, whale oil, kerosene',
            onChanged: (v) => ref.read(inputProvider).fuelAndIlluminant = v,
          ),
          _buildEnumGroup<LockingMechanism>(
            label: 'REGULATING ACTION',
            values: LockingMechanism.values,
            current: ref.watch(inputProvider).lockingMechanismType,
            onSelected: (t) => ref.read(inputProvider).lockingMechanismType = t,
            labelBuilder: (t) => t.label,
          ),
          _buildEnumGroup<BodyMetal>(
            label: 'PALLET METALLURGY & MATERIAL',
            values: BodyMetal.values,
            current: ref.watch(inputProvider).bodyMetal,
            onSelected: (t) => ref.read(inputProvider).bodyMetal = t,
            labelBuilder: (t) => t.label,
          ),
          _monoField(
            label: 'ESCAPE WHEEL TOOTH COUNT',
            ctrl: _airCtrl,
            hint: 'e.g. Bottom-feed air ring, top-feed tubes',
            onChanged: (v) => ref.read(inputProvider).airInflowDesign = v,
          ),
          _monoField(
            label: 'PHYSICAL PROPORTIONS',
            ctrl: _dimCtrl,
            hint: 'e.g. 340mm total height, 85mm reflector, 420g',
            onChanged: (v) => ref.read(inputProvider).physicalProportions = v,
          ),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader('03', 'Archival Record'),
          SizedBox(height: 24.h),
          _buildEnumGroup<PreservationStatus>(
            label: 'PRESERVATION SOUNDNESS',
            values: PreservationStatus.values,
            current: ref.watch(inputProvider).preservationStatus,
            onSelected: (t) => ref.read(inputProvider).preservationStatus = t,
            labelBuilder: (t) => t.label.split(' — ')[0],
          ),
          _monoField(
            label: 'TEMPERATURE RANGE',
            ctrl: _gearCtrl,
            hint: 'Magnetic keys, tip cleaners, leather straps, spare glass...',
            maxLines: 2,
            onChanged: (v) => ref.read(inputProvider).accompanyingGear = v,
          ),
          _monoField(
            label: 'CALIBRATED MILL / KILN',
            ctrl: _stampsCtrl,
            hint: 'Watchmaker inspector numbers, railroad tags, coal company inventory...',
            maxLines: 2,
            onChanged: (v) => ref.read(inputProvider).inspectorAndCollieryStamps = v,
          ),
          _monoField(
            label: 'HOROLOGICAL GROUND ZERO',
            ctrl: _contextCtrl,
            hint: 'e.g. Welsh valleys, Durham Coalfield, Appalachian, Ruhr Basin',
            onChanged: (v) => ref.read(inputProvider).historicalContext = v,
          ),
          _monoField(
            label: 'ARCHIVAL NOTES',
            ctrl: _notesCtrl,
            hint: 'History, instrument type incidents, notable colliery use...',
            maxLines: 5,
            onChanged: (v) => ref.read(inputProvider).archivalNotes = v,
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(String num, String title) {
    return Row(
      children: [
        Text(
          num,
          style: GoogleFonts.ibmPlexMono(
            color: kAccent,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(width: 12.w),
        Container(width: 24.w, height: 1, color: kOutline),
        SizedBox(width: 12.w),
        Text(
          title,
          style: GoogleFonts.cormorantGaramond(
            color: kPrimaryText,
            fontSize: 26.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    final imgPath = ref.watch(imageProvider).getImagePath(
      ref.watch(imageProvider).resultImage,
    );
    final hasImage = imgPath != null && File(imgPath).existsSync();

    return GestureDetector(
      onTap: () => photoBottomSheet(context, ref.read(imageProvider), 0, ref),
      child: Container(
        width: double.infinity,
        height: 200.h,
        decoration: BoxDecoration(
          color: hasImage ? kPanelBg : kAccentSurface,
          borderRadius: BorderRadius.circular(kRadiusStandard),
          border: Border.all(
            color: hasImage ? kAccent.withValues(alpha: 0.35) : kOutline,
            width: hasImage ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(imgPath), fit: BoxFit.cover),
                  Positioned(
                    right: 12.w,
                    bottom: 12.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: kPrimaryText.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(kRadiusPill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_outlined, color: kPanelBg, size: 14.sp),
                          SizedBox(width: 6.w),
                          Text(
                            'Change photo',
                            style: GoogleFonts.sourceSans3(
                              color: kPanelBg,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: kPanelBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: kOutline),
                      boxShadow: const [kShadowSubtle],
                    ),
                    child: Icon(Icons.add_a_photo_outlined, color: kAccent, size: 26.sp),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'Add macro photograph',
                    style: GoogleFonts.sourceSans3(
                      color: kPrimaryText,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Camera or photo library',
                    style: GoogleFonts.sourceSans3(
                      color: kSecondaryText,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Opacity(
                    opacity: 0.35,
                    child: EscapementMotif(
                      architecture: ref.watch(inputProvider).apparatusClassification,
                      width: 40.w,
                      height: 40.w,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _monoField({
    required String label,
    required TextEditingController ctrl,
    required Function(String) onChanged,
    String? hint,
    int maxLines = 1,
    bool hasError = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.ibmPlexMono(
              color: hasError ? kAccent : kSecondaryText,
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: ctrl,
            onChanged: onChanged,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: GoogleFonts.sourceSans3(
              color: kPrimaryText,
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.sourceSans3(
                color: kSecondaryText.withValues(alpha: 0.35),
                fontSize: 13.sp,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: hasError ? kAccent.withValues(alpha: 0.5) : kOutline,
                  width: 1.0,
                ),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: kAccent, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              filled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnumGroup<T>({
    required String label,
    required List<T> values,
    required T current,
    required Function(T) onSelected,
    required String Function(T) labelBuilder,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: values.map((val) {
              final isSel = val == current;
              return GestureDetector(
                onTap: () => onSelected(val),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 190),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSel ? kAccent : kPanelBg,
                    borderRadius: BorderRadius.circular(kRadiusSubtle),
                    border: Border.all(
                      color: isSel ? kAccent : kOutline,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    labelBuilder(val),
                    style: GoogleFonts.sourceSans3(
                      color: isSel ? kBackground : kPrimaryText,
                      fontSize: 12.sp,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isIdEmpty = _cabinetCtrl.text.trim().isEmpty;
    final isDisabled = _currentPage == 0 && isIdEmpty;
    final isLast = _currentPage >= 2;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.w,
        8.h,
        20.w,
        MediaQuery.of(context).padding.bottom + 16.h,
      ),
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusPill),
          border: Border.all(color: kOutline),
          boxShadow: const [kShadowFloat],
        ),
        child: Row(
          children: [
            if (_currentPage > 0)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _goToPage(_currentPage - 1),
                  borderRadius: BorderRadius.circular(kRadiusPill),
                  child: Container(
                    height: 48.h,
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_rounded, color: kPrimaryText, size: 20.sp),
                        SizedBox(width: 6.w),
                        Text(
                          'Back',
                          style: GoogleFonts.sourceSans3(
                            color: kPrimaryText,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_currentPage > 0) SizedBox(width: 8.w),
            Expanded(
              child: Material(
                color: isDisabled ? kOutline.withValues(alpha: 0.5) : kAccent,
                borderRadius: BorderRadius.circular(kRadiusPill),
                elevation: isDisabled ? 0 : 0,
                child: InkWell(
                  onTap: isDisabled
                      ? null
                      : () {
                          if (_currentPage < 2) {
                            _goToPage(_currentPage + 1);
                          } else {
                            _save();
                          }
                        },
                  borderRadius: BorderRadius.circular(kRadiusPill),
                  child: Container(
                    height: 48.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(kRadiusPill),
                      boxShadow: isDisabled ? null : const [kShadowBlue],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLast
                              ? (widget.isEdit ? 'Update record' : 'Save to cabinet')
                              : 'Continue',
                          style: GoogleFonts.sourceSans3(
                            color: isDisabled ? kSecondaryText : kPanelBg,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!isLast) ...[
                          SizedBox(width: 6.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: isDisabled ? kSecondaryText : kPanelBg,
                            size: 18.sp,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavingDialog extends StatelessWidget {
  const _SavingDialog();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kPanelBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusMedium),
      ),
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 44.w,
              height: 44.w,
              child: const CircularProgressIndicator(
                color: kAccent,
                strokeWidth: 2,
              ),
            ),
            SizedBox(height: 28.h),
            Text(
              'COMMITTING TO CABINET',
              style: GoogleFonts.ibmPlexMono(
                color: kPrimaryText,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Recording mechanism data to the safety archive.',
              textAlign: TextAlign.center,
              style: GoogleFonts.sourceSans3(
                color: kSecondaryText,
                fontSize: 13.sp,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EraInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    final regExp = RegExp(r'^\d{0,4}s?$');
    if (regExp.hasMatch(text)) return newValue;
    return oldValue;
  }
}
