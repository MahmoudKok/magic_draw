part of 'slime_bloc.dart';

abstract class SlimeEvent {}

class PressScreenEvent extends SlimeEvent {
  final Offset position;
  PressScreenEvent(this.position);
}

class ReleaseScreenEvent extends SlimeEvent {}
