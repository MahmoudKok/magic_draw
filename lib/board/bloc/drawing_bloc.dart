import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../screens/white_board_drawing_screen.dart';

part 'drawing_event.dart';
part 'drawing_state.dart';

class DrawingBloc extends Bloc<DrawingEvent, DrawingState> {
  static const int maxPoints = 50;
  DateTime _lastUpdate = DateTime.now();

  DrawingBloc() : super(const DrawingState([], null)) {
    // Continuous cleanup stream
    Stream.periodic(const Duration(milliseconds: 16)).listen((_) {
      if (!state.isDrawing && state.points.isNotEmpty) {
        final now = DateTime.now();
        final updatedPoints = List<DrawnPoint>.from(state.points)
          ..removeWhere(
              (p) => now.difference(p.timestamp).inMilliseconds >= 500);
        if (updatedPoints.length != state.points.length) {
          emit(state.copyWith(points: updatedPoints));
        }
      }
    });

    on<AddPointEvent>((event, emit) {
      final now = DateTime.now();
      if (now.difference(_lastUpdate).inMilliseconds < 16) return;
      _lastUpdate = now;

      final newPoints = List<DrawnPoint>.from(state.points)
        ..add(DrawnPoint(
          position: event.position,
          timestamp: now,
          color: event.color,
        ));
      if (newPoints.length > maxPoints) {
        newPoints.removeRange(0, newPoints.length - maxPoints);
      }
      newPoints.removeWhere(
          (p) => now.difference(p.timestamp).inMilliseconds >= 500);
      emit(state.copyWith(points: newPoints, isDrawing: true));
    });

    on<SetPressPositionEvent>((event, emit) {
      final now = DateTime.now();
      final updatedPoints = List<DrawnPoint>.from(state.points)
        ..removeWhere((p) => now.difference(p.timestamp).inMilliseconds >= 500);

      if (event.position == null) {
        // Stop drawing, let points fade naturally
        emit(state.copyWith(
            points: updatedPoints, pressPosition: null, isDrawing: false));
      } else {
        emit(state.copyWith(
            points: updatedPoints,
            pressPosition: event.position,
            isDrawing: true));
      }
    });
  }
}
