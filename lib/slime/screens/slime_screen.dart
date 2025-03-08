import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/slime_bloc.dart';

class SlimeScreen extends StatelessWidget {
  const SlimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SlimeBloc(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onPanDown: (details) {
            context
                .read<SlimeBloc>()
                .add(PressScreenEvent(details.localPosition));
          },
          onPanUpdate: (details) {
            context
                .read<SlimeBloc>()
                .add(PressScreenEvent(details.localPosition));
          },
          onPanEnd: (_) {
            context.read<SlimeBloc>().add(ReleaseScreenEvent());
          },
          child: BlocBuilder<SlimeBloc, SlimeState>(
            builder: (context, state) {
              return CustomPaint(
                painter: SlimePainter(
                  pressPosition: state.pressPosition,
                  deformation: state.deformation,
                ),
                child: const SizedBox.expand(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class SlimePainter extends CustomPainter {
  final Offset? pressPosition;
  final double deformation;

  SlimePainter({this.pressPosition, required this.deformation});

  @override
  void paint(Canvas canvas, Size size) {
    final slimePaint = Paint()
      ..color = Colors.green.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    const slimeRadius = 100.0;

    if (pressPosition == null || deformation == 0.0) {
      // Default circular slime
      canvas.drawCircle(center, slimeRadius, slimePaint);
    } else {
      // Deformed slime with push-down effect
      final path = Path();
      final pressOffset = pressPosition! - center;
      final pressDistance = pressOffset.distance.clamp(0.0, slimeRadius);
      final pressDirection =
          pressOffset / (pressDistance == 0 ? 1 : pressDistance);

      // Calculate deformation depth
      final deformDepth = slimeRadius * deformation * 0.5;
      final deformPoint = center + pressDirection * (slimeRadius - deformDepth);

      // Draw a smooth, slime-like shape
      path.moveTo(center.dx - slimeRadius, center.dy); // Left edge
      for (double angle = 0; angle < 2 * math.pi; angle += 0.1) {
        final basePoint = Offset(
          center.dx + math.cos(angle) * slimeRadius,
          center.dy + math.sin(angle) * slimeRadius,
        );
        final vectorToPress = basePoint - deformPoint;
        final distanceToPress = vectorToPress.distance;
        final deformFactor =
            (1 - (distanceToPress / slimeRadius).clamp(0.0, 1.0)) * deformation;
        final adjustedPoint = basePoint - vectorToPress * deformFactor * 0.5;
        if (angle == 0) {
          path.moveTo(adjustedPoint.dx, adjustedPoint.dy);
        } else {
          path.lineTo(adjustedPoint.dx, adjustedPoint.dy);
        }
      }
      path.close();

      canvas.drawPath(path, slimePaint);

      // Add gooey drip effect
      final dripPaint = Paint()
        ..color = Colors.green.withOpacity(0.6)
        ..style = PaintingStyle.fill;
      final dripPath = Path();
      final dripBase = deformPoint + pressDirection * deformDepth * 0.5;
      dripPath.moveTo(dripBase.dx - 10, dripBase.dy);
      dripPath.quadraticBezierTo(
        dripBase.dx,
        dripBase.dy + 20 * deformation,
        dripBase.dx + 10,
        dripBase.dy,
      );
      canvas.drawPath(dripPath, dripPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SlimePainter oldDelegate) {
    return oldDelegate.pressPosition != pressPosition ||
        oldDelegate.deformation != deformation;
  }
}
