import 'dart:math';
import 'package:flutter/material.dart';

class ProgressRing extends StatefulWidget {
  final double progress;
  final Color color;
  final double strokeWidth;
  final double size;
  final Widget? child;
  final List<Color>? gradientColors;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.color,
    this.strokeWidth = 10,
    this.size = 160,
    this.child,
    this.gradientColors,
  });

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _SegmentedRingPainter(
              progress: _animation.value,
              color: widget.color,
              strokeWidth: widget.strokeWidth,
              gradientColors: widget.gradientColors,
            ),
            child: Center(child: widget.child),
          ),
        );
      },
    );
  }
}

class _SegmentedRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final List<Color>? gradientColors;

  static const int _totalSegments = 24;
  static const double _gapDegrees = 5.0;
  static const double _startAngle = -225.0; // start bottom-left
  static const double _totalSweep = 270.0;  // 3/4 arc (open at bottom)

  _SegmentedRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth - 4) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final totalGap = _gapDegrees * _totalSegments;
    final segmentDegrees = (_totalSweep - totalGap) / _totalSegments;
    final filledSegments = (_totalSegments * progress).round();

    // Outer subtle ring (decorative)
    final outerRingPaint = Paint()
      ..color = color.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius + strokeWidth / 2 + 2, outerRingPaint);

    // Inner subtle ring (decorative)
    canvas.drawCircle(center, radius - strokeWidth / 2 - 2, outerRingPaint);

    // Draw each segment
    for (var i = 0; i < _totalSegments; i++) {
      final startDeg =
          _startAngle + i * (segmentDegrees + _gapDegrees);
      final startRad = startDeg * pi / 180;
      final sweepRad = segmentDegrees * pi / 180;

      final isFilled = i < filledSegments;

      if (isFilled) {
        // Glow behind filled segment
        final glowPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 6
          ..strokeCap = StrokeCap.round
          ..color = _colorForSegment(i, filledSegments).withOpacity(0.20)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawArc(rect, startRad, sweepRad, false, glowPaint);

        // Filled segment
        final fillPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = _colorForSegment(i, filledSegments);
        canvas.drawArc(rect, startRad, sweepRad, false, fillPaint);
      } else {
        // Empty segment — subtle track
        final emptyPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth - 2
          ..strokeCap = StrokeCap.round
          ..color = color.withOpacity(0.07);
        canvas.drawArc(rect, startRad, sweepRad, false, emptyPaint);
      }
    }

    // Leading dot at end of filled portion
    if (filledSegments > 0 && progress > 0.03) {
      final lastSegIndex = filledSegments - 1;
      final lastSegEnd = _startAngle +
          lastSegIndex * (segmentDegrees + _gapDegrees) +
          segmentDegrees;
      final endRad = lastSegEnd * pi / 180;
      final dotCenter = Offset(
        center.dx + radius * cos(endRad),
        center.dy + radius * sin(endRad),
      );

      final dotColor = _colorForSegment(lastSegIndex, filledSegments);

      // Outer glow
      canvas.drawCircle(
        dotCenter,
        strokeWidth / 2 + 3,
        Paint()..color = dotColor.withOpacity(0.25),
      );
      // Solid dot
      canvas.drawCircle(
        dotCenter,
        strokeWidth / 2,
        Paint()..color = dotColor,
      );
      // White center
      canvas.drawCircle(
        dotCenter,
        2.5,
        Paint()..color = Colors.white,
      );
    }

    // Small decorative dots at start and end of the arc
    final startRad = _startAngle * pi / 180;
    final endRad = (_startAngle + _totalSweep) * pi / 180;
    final dotPaint = Paint()..color = color.withOpacity(0.15);
    canvas.drawCircle(
      Offset(
        center.dx + (radius) * cos(startRad),
        center.dy + (radius) * sin(startRad),
      ),
      2,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(
        center.dx + (radius) * cos(endRad),
        center.dy + (radius) * sin(endRad),
      ),
      2,
      dotPaint,
    );
  }

  Color _colorForSegment(int index, int total) {
    if (gradientColors != null && gradientColors!.length >= 2) {
      final t = total > 1 ? index / (total - 1) : 0.0;
      return Color.lerp(
        gradientColors!.first,
        gradientColors!.last,
        t,
      )!;
    }
    return color;
  }

  @override
  bool shouldRepaint(_SegmentedRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
