import 'package:flutter/material.dart';

/// Smoothly animates between numeric values, rendering with [format].
class AnimatedAmount extends StatelessWidget {
  final double value;
  final String Function(double value) format;
  final TextStyle? style;
  final Duration duration;

  const AnimatedAmount({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) => Text(format(animated), style: style),
    );
  }
}
