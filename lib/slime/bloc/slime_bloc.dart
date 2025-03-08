import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'slime_event.dart';
part 'slime_state.dart';

class SlimeBloc extends Bloc<SlimeEvent, SlimeState> {
  SlimeBloc() : super(const SlimeState()) {
    on<PressScreenEvent>((event, emit) {
      // Immediately set press position and start deformation
      emit(state.copyWith(pressPosition: event.position, deformation: 1.0));
    });

    on<ReleaseScreenEvent>((event, emit) async {
      // Gradually reduce deformation back to 0 over 500ms
      const int steps = 20; // Number of animation steps
      const int durationMs = 500; // Total duration in milliseconds
      const double stepTime = durationMs / steps; // Time per step in ms

      for (int i = steps; i >= 0; i--) {
        final deformation = i / steps;
        emit(state.copyWith(pressPosition: null, deformation: deformation));
        await Future.delayed(Duration(milliseconds: stepTime.toInt()));
      }
    });
  }
}
