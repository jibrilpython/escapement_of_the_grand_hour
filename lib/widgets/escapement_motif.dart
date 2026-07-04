import 'package:flutter/material.dart';
import 'package:escapement_of_the_grand_hour/enum/my_enums.dart';
import 'package:escapement_of_the_grand_hour/utils/const.dart';

/// Minimal escapement silhouette for list cards — horologists identify type by shape.
class EscapementMotif extends StatelessWidget {
  final ApparatusClassification architecture;
  final bool operational;
  final double width;
  final double height;

  const EscapementMotif({
    super.key,
    required this.architecture,
    this.operational = true,
    this.width = 44,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: EscapementMotifPainter(
        architecture: architecture,
        color: operational ? kAccent : kSecondaryAccent,
      ),
    );
  }
}

class EscapementMotifPainter extends CustomPainter {
  final ApparatusClassification architecture;
  final Color color;

  EscapementMotifPainter({
    required this.architecture,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    switch (architecture) {
      case ApparatusClassification.vergeFoliot:
        _drawVerge(canvas, size, stroke, fill);
      case ApparatusClassification.englishLever:
      case ApparatusClassification.coAxial:
        _drawLever(canvas, size, stroke, fill);
      case ApparatusClassification.detentChronometer:
      case ApparatusClassification.doubleWheelChronometer:
        _drawDetent(canvas, size, stroke, fill);
      case ApparatusClassification.recoilAnchor:
      case ApparatusClassification.deadbeatAnchor:
        _drawAnchor(canvas, size, stroke, fill);
      case ApparatusClassification.cylinder:
        _drawCylinder(canvas, size, stroke, fill);
      case ApparatusClassification.other:
        _drawLever(canvas, size, stroke, fill);
    }
  }

  void _drawLever(Canvas canvas, Size size, Paint stroke, Paint fill) {
    final cx = size.width * 0.5;
    final path = Path()
      ..moveTo(cx, size.height * 0.12)
      ..lineTo(cx, size.height * 0.42)
      ..lineTo(size.width * 0.22, size.height * 0.58)
      ..lineTo(size.width * 0.78, size.height * 0.58)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
    canvas.drawCircle(
      Offset(size.width * 0.22, size.height * 0.58),
      size.width * 0.07,
      stroke,
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.58),
      size.width * 0.07,
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.12, size.height * 0.82),
      Offset(size.width * 0.88, size.height * 0.82),
      stroke,
    );
  }

  void _drawVerge(Canvas canvas, Size size, Paint stroke, Paint fill) {
    final cx = size.width * 0.5;
    canvas.drawLine(
      Offset(cx, size.height * 0.1),
      Offset(cx, size.height * 0.88),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.28, size.height * 0.38),
      Offset(size.width * 0.72, size.height * 0.52),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.28, size.height * 0.52),
      Offset(size.width * 0.72, size.height * 0.38),
      stroke,
    );
    canvas.drawCircle(Offset(cx, size.height * 0.78), size.width * 0.16, stroke);
  }

  void _drawDetent(Canvas canvas, Size size, Paint stroke, Paint fill) {
    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.18,
        size.width * 0.82,
        size.height * 0.55,
      );
    canvas.drawPath(path, stroke);
    canvas.drawLine(
      Offset(size.width * 0.62, size.height * 0.48),
      Offset(size.width * 0.78, size.height * 0.72),
      stroke,
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.72),
      size.width * 0.06,
      stroke,
    );
  }

  void _drawAnchor(Canvas canvas, Size size, Paint stroke, Paint fill) {
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.14)
      ..lineTo(size.width * 0.34, size.height * 0.62)
      ..lineTo(size.width * 0.66, size.height * 0.62)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.78),
        radius: size.width * 0.22,
      ),
      3.4,
      2.0,
      false,
      stroke,
    );
  }

  void _drawCylinder(Canvas canvas, Size size, Paint stroke, Paint fill) {
    canvas.drawCircle(
      Offset(size.width * 0.34, size.height * 0.55),
      size.width * 0.14,
      stroke,
    );
    canvas.drawCircle(
      Offset(size.width * 0.66, size.height * 0.55),
      size.width * 0.1,
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.18),
      Offset(size.width * 0.5, size.height * 0.42),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant EscapementMotifPainter old) =>
      old.architecture != architecture || old.color != color;
}

bool isOperationalEscapement(PreservationStatus status) {
  return status == PreservationStatus.museumGrade ||
      status == PreservationStatus.fullyOperational ||
      status == PreservationStatus.serviceable;
}
