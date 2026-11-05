import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'ui_kit.dart';

/// A circular gauge showing a 0–100 match score, painted with a soft gradient
/// arc and rounded cap. Colour-coded by strength, it gives students an instant
/// read on how well an internship fits them.
class ScoreRing extends StatelessWidget {
  final double score; // 0–100
  final double size;

  const ScoreRing({super.key, required this.score, this.size = 58});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final MatchPalette p = matchPalette(score, scheme.brightness);
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: score.clamp(0, 100)),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (BuildContext context, double value, _) {
          return CustomPaint(
            painter: _RingPainter(
              progress: (value / 100).clamp(0.0, 1.0),
              color: p.base,
              track: scheme.surfaceContainerHighest,
              stroke: size * 0.1,
            ),
            child: Center(
              child: Text(
                '${value.round()}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: size * 0.3,
                  color: p.fg,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color track;
  final double stroke;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.track,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width - stroke) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    const double start = -math.pi / 2; // 12 o'clock
    final double sweep = 2 * math.pi * progress;
    final Paint arcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        transform: const GradientRotation(-math.pi / 2),
        colors: <Color>[color.withValues(alpha: 0.55), color],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, sweep, false, arcPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.track != track ||
      old.stroke != stroke;
}
