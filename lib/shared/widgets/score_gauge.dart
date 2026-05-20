import 'dart:math';
import 'package:flutter/material.dart';

/// Horizontal segmented gauge bar — replaces the circular ProgressRing
/// on the dashboard Lung Score card.
class ScoreGauge extends StatefulWidget {
  final double progress; // 0.0 → 1.0
  final Color color;
  final List<Color>? gradientColors;
  final double height;

  const ScoreGauge({
    super.key,
    required this.progress,
    required this.color,
    this.gradientColors,
    this.height = 14,
  });

  @override
  State<ScoreGauge> createState() => _ScoreGaugeState();
}

class _ScoreGaugeState extends State<ScoreGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _anim = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(ScoreGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _anim = Tween<double>(
        begin: _anim.value,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
      );
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: _GaugePainter(
            progress: _anim.value,
            color: widget.color,
            gradientColors: widget.gradientColors,
            barHeight: widget.height,
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final List<Color>? gradientColors;
  final double barHeight;

  static const int _segments = 20;
  static const double _gapRatio = 0.25; // gap as fraction of segment width

  _GaugePainter({
    required this.progress,
    required this.color,
    this.gradientColors,
    required this.barHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final totalGapWidth = size.width * _gapRatio * _segments / (_segments + _gapRatio * _segments);
    final gapWidth = totalGapWidth / (_segments - 1);
    final segWidth = (size.width - gapWidth * (_segments - 1)) / _segments;
    final radius = barHeight / 2;
    final filledCount = (_segments * progress).round();

    for (var i = 0; i < _segments; i++) {
      final x = i * (segWidth + gapWidth);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, segWidth, barHeight),
        Radius.circular(radius),
      );

      if (i < filledCount) {
        // Glow
        final glowColor = _segColor(i, filledCount).withOpacity(0.25);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x - 1, -1, segWidth + 2, barHeight + 2),
            Radius.circular(radius + 1),
          ),
          Paint()
            ..color = glowColor
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
        // Filled segment
        canvas.drawRRect(rect, Paint()..color = _segColor(i, filledCount));
      } else {
        // Empty segment
        canvas.drawRRect(rect, Paint()..color = color.withOpacity(0.08));
      }
    }
  }

  Color _segColor(int index, int total) {
    if (gradientColors != null && gradientColors!.length >= 2) {
      final t = total > 1 ? index / (total - 1) : 0.0;
      return Color.lerp(gradientColors!.first, gradientColors!.last, t)!;
    }
    return color;
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.progress != progress || old.color != color;
}
