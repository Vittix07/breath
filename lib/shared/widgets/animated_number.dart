import 'package:flutter/material.dart';

class AnimatedNumber extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final String? suffix;

  const AnimatedNumber({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 800),
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        return Text(
          '${val.round()}${suffix ?? ''}',
          style: style,
        );
      },
    );
  }
}

class AnimatedDouble extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final int decimals;
  final String? suffix;

  const AnimatedDouble({
    super.key,
    required this.value,
    this.style,
    this.decimals = 1,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        return Text(
          '${val.toStringAsFixed(decimals)}${suffix ?? ''}',
          style: style,
        );
      },
    );
  }
}
