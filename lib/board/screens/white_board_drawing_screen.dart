import 'dart:math' as math;

import 'package:flutter/material.dart';

class DrawnPoint {
  final Offset position;
  final DateTime timestamp;
  final Color color;

  DrawnPoint(
      {required this.position, required this.timestamp, required this.color});
}

class MagicLinesPainter extends CustomPainter {
  final List<DrawnPoint> points;
  final double animationValue;
  final Offset? pressPosition;
  final math.Random _random = math.Random();
  final LinearGradient goldGradient = const LinearGradient(
    colors: [
      Color(0xFFD4AF37),
      Color(0xFFFFD700),
      Color(0xFFB8860B),
      Color(0xFFEEE8AA),
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  MagicLinesPainter({
    required this.points,
    required this.animationValue,
    this.pressPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    final headPaint = Paint()..style = PaintingStyle.fill;

    final sparklePaint = Paint()..style = PaintingStyle.fill;

    final distortedPoints =
        points.map((p) => _apply3DTwist([p.position], size)[0]).toList();

    for (int i = 0; i < distortedPoints.length - 1; i++) {
      final age = DateTime.now().difference(points[i].timestamp).inMilliseconds;
      final opacity = (1.0 - (age / 500.0)).clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      final segment = [distortedPoints[i], distortedPoints[i + 1]];

      glowPaint.color = points[i].color.withOpacity(opacity * 0.7);
      canvas.drawLine(segment[0], segment[1], glowPaint);

      linePaint.color = points[i].color.withOpacity(opacity);
      canvas.drawLine(segment[0], segment[1], linePaint);

      if (i == distortedPoints.length - 2 && distortedPoints.length >= 2) {
        headPaint.color = points[i + 1].color.withOpacity(opacity);
        canvas.drawCircle(
            distortedPoints[i + 1],
            6.0,
            headPaint
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0));
        canvas.drawCircle(
            distortedPoints[i + 1], 4.0, headPaint..maskFilter = null);
      }
    }

    final sparkleCount = math.min(5, distortedPoints.length - 1);
    for (int i = distortedPoints.length - sparkleCount;
        i < distortedPoints.length - 1;
        i++) {
      if (i < 0) continue;
      final age = DateTime.now().difference(points[i].timestamp).inMilliseconds;
      final opacity = (1.0 - (age / 500.0)).clamp(0.0, 1.0);
      if (opacity <= 0 || _random.nextDouble() >= 0.3) continue;

      final segment = [distortedPoints[i], distortedPoints[i + 1]];
      final dx = segment[1].dx - segment[0].dx;
      final dy = segment[1].dy - segment[0].dy;
      final length = math.sqrt(dx * dx + dy * dy);
      final normalX = -dy / length;
      final normalY = dx / length;

      final t = _random.nextDouble();
      final basePosition =
          Offset(segment[0].dx + dx * t, segment[0].dy + dy * t);
      final offsetDistance = 10.0;
      final side = _random.nextBool() ? 1.0 : -1.0;
      final sparklePosition = Offset(
        basePosition.dx + normalX * offsetDistance * side,
        basePosition.dy + normalY * offsetDistance * side,
      );

      final sparkleWidth = 2.0;
      final sparkleHeight = 4.0;
      final rotationAngle =
          math.sin(animationValue * 2 * math.pi) * math.pi / 6;

      sparklePaint.shader = goldGradient.createShader(Rect.fromLTWH(
        sparklePosition.dx - sparkleWidth,
        sparklePosition.dy - sparkleHeight,
        sparkleWidth * 2,
        sparkleHeight * 2,
      ));

      canvas.save();
      canvas.translate(sparklePosition.dx, sparklePosition.dy);
      canvas.rotate(rotationAngle);
      _drawRhombus(
          canvas, Offset.zero, sparkleWidth, sparkleHeight, sparklePaint);
      canvas.restore();
    }
  }

  void _drawRhombus(
      Canvas canvas, Offset center, double width, double height, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - height);
    path.lineTo(center.dx + width, center.dy);
    path.lineTo(center.dx, center.dy + height);
    path.lineTo(center.dx - width, center.dy);
    path.close();
    canvas.drawPath(path, paint);
  }

  List<Offset> _apply3DTwist(List<Offset> segment, Size size) {
    if (pressPosition == null) return segment;

    List<Offset> distortedSegment = [];
    final center = pressPosition!;
    const twistRadius = 100.0;
    const maxTwist = math.pi / 4;

    for (var point in segment) {
      final distance = (point - center).distance;
      if (distance < twistRadius) {
        final twistFactor = (1 - distance / twistRadius) * animationValue;
        final dx = point.dx - center.dx;
        final dy = point.dy - center.dy;

        final twistedAngle = twistFactor * maxTwist;
        final newX = center.dx +
            dx * math.cos(twistedAngle) -
            dy * math.sin(twistedAngle);
        final newY = center.dy +
            dx * math.sin(twistedAngle) +
            dy * math.cos(twistedAngle);

        final depthFactor = 1 + (twistFactor * 0.2);
        final finalX = center.dx + (newX - center.dx) * depthFactor;
        final finalY = center.dy + (newY - center.dy) * depthFactor;

        distortedSegment.add(Offset(finalX, finalY));
      } else {
        distortedSegment.add(point);
      }
    }
    return distortedSegment;
  }

  @override
  bool shouldRepaint(covariant MagicLinesPainter oldDelegate) {
    return oldDelegate.points.length != points.length ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.pressPosition != pressPosition ||
        oldDelegate.points.any(
            (p) => DateTime.now().difference(p.timestamp).inMilliseconds < 500);
  }
}
