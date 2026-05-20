import 'dart:math';
import 'package:flutter/material.dart';

/// Clean, stylised lung silhouette that fills with animated liquid.
/// Inspired by minimal medical icon style — single stroke outline,
/// smooth curves, wide proportions.
class LungFillVisual extends StatefulWidget {
  final double fillLevel; // 0.0 → 1.0
  final Color liquidColor;
  final List<Color>? gradientColors;
  final double width;
  final double height;

  const LungFillVisual({
    super.key,
    required this.fillLevel,
    required this.liquidColor,
    this.gradientColors,
    this.width = 130,
    this.height = 140,
  });

  @override
  State<LungFillVisual> createState() => _LungFillVisualState();
}

class _LungFillVisualState extends State<LungFillVisual>
    with TickerProviderStateMixin {
  late AnimationController _waveCtrl;
  late AnimationController _fillCtrl;
  late Animation<double> _fillAnim;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _fillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _fillAnim = Tween<double>(begin: 0, end: widget.fillLevel).animate(
      CurvedAnimation(parent: _fillCtrl, curve: Curves.easeOutCubic),
    );
    _fillCtrl.forward();
  }

  @override
  void didUpdateWidget(LungFillVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fillLevel != widget.fillLevel) {
      _fillAnim = Tween<double>(
        begin: _fillAnim.value,
        end: widget.fillLevel,
      ).animate(
        CurvedAnimation(parent: _fillCtrl, curve: Curves.easeOutCubic),
      );
      _fillCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _fillCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_waveCtrl, _fillAnim]),
      builder: (context, _) {
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: CustomPaint(
            painter: _LungPainter(
              fillLevel: _fillAnim.value,
              wavePhase: _waveCtrl.value * 2 * pi,
              liquidColor: widget.liquidColor,
              gradientColors: widget.gradientColors,
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════

class _LungPainter extends CustomPainter {
  final double fillLevel;
  final double wavePhase;
  final Color liquidColor;
  final List<Color>? gradientColors;

  _LungPainter({
    required this.fillLevel,
    required this.wavePhase,
    required this.liquidColor,
    this.gradientColors,
  });

  // ── paths ────────────────────────────────────────────────────────────────

  Path _leftLung(double w, double h) {
    return Path()
      ..moveTo(w * 0.44, h * 0.17)
      // apex — sweeps up then wide to the left
      ..cubicTo(
        w * 0.36, h * 0.08,
        w * 0.12, h * 0.08,
        w * 0.05, h * 0.28,
      )
      // outer wall — smooth wide curve downward
      ..cubicTo(
        w * 0.00, h * 0.46,
        w * 0.00, h * 0.68,
        w * 0.08, h * 0.84,
      )
      // base — rounded bottom
      ..cubicTo(
        w * 0.14, h * 0.95,
        w * 0.28, h * 0.99,
        w * 0.40, h * 0.92,
      )
      // inner wall — relatively straight up back to hilum
      ..cubicTo(
        w * 0.44, h * 0.78,
        w * 0.46, h * 0.48,
        w * 0.44, h * 0.17,
      )
      ..close();
  }

  Path _rightLung(double w, double h) {
    return Path()
      ..moveTo(w * 0.56, h * 0.17)
      // apex
      ..cubicTo(
        w * 0.64, h * 0.08,
        w * 0.88, h * 0.08,
        w * 0.95, h * 0.28,
      )
      // outer wall
      ..cubicTo(
        w * 1.00, h * 0.46,
        w * 1.00, h * 0.68,
        w * 0.92, h * 0.84,
      )
      // base
      ..cubicTo(
        w * 0.86, h * 0.95,
        w * 0.72, h * 0.99,
        w * 0.60, h * 0.92,
      )
      // inner wall
      ..cubicTo(
        w * 0.56, h * 0.78,
        w * 0.54, h * 0.48,
        w * 0.56, h * 0.17,
      )
      ..close();
  }

  Path _combinedLungs(double w, double h) {
    return Path()
      ..addPath(_leftLung(w, h), Offset.zero)
      ..addPath(_rightLung(w, h), Offset.zero);
  }

  // ── paint ────────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final lungs = _combinedLungs(w, h);

    // 1 — trachea (behind lungs)
    _drawTrachea(canvas, w, h);

    // 2 — lung background fill (very faint)
    canvas.drawPath(
      lungs,
      Paint()
        ..color = liquidColor.withOpacity(0.05)
        ..style = PaintingStyle.fill,
    );

    // 3 — liquid (clipped inside lungs)
    if (fillLevel > 0.005) {
      canvas.save();
      canvas.clipPath(lungs);
      _drawLiquid(canvas, w, h);
      canvas.restore();
    }

    // 4 — outline
    canvas.drawPath(
      lungs,
      Paint()
        ..color = liquidColor.withOpacity(0.40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  // ── trachea ──────────────────────────────────────────────────────────────

  void _drawTrachea(Canvas canvas, double w, double h) {
    // Simple centered tube
    final trachW = w * 0.09;
    final trachL = (w - trachW) / 2;
    final trachTop = h * 0.00;
    final trachBot = h * 0.18;
    final radius = trachW / 2;

    // Fill
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(trachL, trachTop, trachL + trachW, trachBot),
        Radius.circular(radius),
      ),
      Paint()..color = liquidColor.withOpacity(0.08),
    );

    // Outline
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(trachL, trachTop, trachL + trachW, trachBot),
        Radius.circular(radius),
      ),
      Paint()
        ..color = liquidColor.withOpacity(0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Two subtle bronchi lines going into each lung
    final bronchPaint = Paint()
      ..color = liquidColor.withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Left bronchus
    final lBr = Path()
      ..moveTo(w * 0.50, h * 0.16)
      ..quadraticBezierTo(w * 0.46, h * 0.19, w * 0.44, h * 0.22);
    canvas.drawPath(lBr, bronchPaint);

    // Right bronchus
    final rBr = Path()
      ..moveTo(w * 0.50, h * 0.16)
      ..quadraticBezierTo(w * 0.54, h * 0.19, w * 0.56, h * 0.22);
    canvas.drawPath(rBr, bronchPaint);
  }

  // ── liquid ───────────────────────────────────────────────────────────────

  void _drawLiquid(Canvas canvas, double w, double h) {
    // Lungs span roughly y ∈ [0.08h .. 0.99h].
    final lungTop = h * 0.08;
    final lungBot = h * 0.99;
    final lungRange = lungBot - lungTop;
    final baseY = lungBot - fillLevel * lungRange;

    final amp1 = h * 0.014;
    final amp2 = h * 0.008;

    // ── primary wave ──
    final wave1 = Path()..moveTo(0, h);
    for (double x = 0; x <= w; x += 1) {
      final y = baseY +
          amp1 * sin(x / w * 4 * pi + wavePhase) +
          amp2 * sin(x / w * 7 * pi + wavePhase * 1.4 + 0.8);
      wave1.lineTo(x, y);
    }
    wave1.lineTo(w, h);
    wave1.close();

    final cols = gradientColors ?? [liquidColor, liquidColor];
    canvas.drawPath(
      wave1,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cols.first.withOpacity(0.55),
            cols.last.withOpacity(0.85),
          ],
        ).createShader(Rect.fromLTWH(0, baseY, w, h - baseY)),
    );

    // ── secondary wave (depth) ──
    final wave2 = Path()..moveTo(0, h);
    final baseY2 = baseY + h * 0.010;
    for (double x = 0; x <= w; x += 1) {
      final y = baseY2 +
          amp1 * 0.55 * sin(x / w * 3.2 * pi + wavePhase * 0.65 + 1.2);
      wave2.lineTo(x, y);
    }
    wave2.lineTo(w, h);
    wave2.close();
    canvas.drawPath(wave2, Paint()..color = cols.last.withOpacity(0.18));

    // ── specular highlight band near surface ──
    final hl = Path();
    for (double x = 0; x <= w; x += 1) {
      final y = baseY +
          amp1 * sin(x / w * 4 * pi + wavePhase) +
          amp2 * sin(x / w * 7 * pi + wavePhase * 1.4 + 0.8);
      if (x == 0) {
        hl.moveTo(x, y);
      } else {
        hl.lineTo(x, y);
      }
    }
    for (double x = w; x >= 0; x -= 1) {
      final y = baseY +
          amp1 * sin(x / w * 4 * pi + wavePhase) +
          amp2 * sin(x / w * 7 * pi + wavePhase * 1.4 + 0.8) +
          h * 0.022;
      hl.lineTo(x, y);
    }
    hl.close();
    canvas.drawPath(hl, Paint()..color = Colors.white.withOpacity(0.20));
  }

  @override
  bool shouldRepaint(_LungPainter old) => true;
}
