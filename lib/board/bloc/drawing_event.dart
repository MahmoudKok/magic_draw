part of 'drawing_bloc.dart';

class DrawingEvent {}

class AddPointEvent extends DrawingEvent {
  final Offset position;
  final Color color;
  AddPointEvent(this.position, this.color);
}

class SetPressPositionEvent extends DrawingEvent {
  final Offset? position;
  SetPressPositionEvent(this.position);
}
