part of 'drawing_bloc.dart';

class DrawingState extends Equatable {
  final List<DrawnPoint> points;
  final Offset? pressPosition;
  final bool isDrawing;

  const DrawingState(this.points, this.pressPosition, {this.isDrawing = false});

  DrawingState copyWith(
      {List<DrawnPoint>? points, Offset? pressPosition, bool? isDrawing}) {
    return DrawingState(
      points ?? this.points,
      pressPosition ?? this.pressPosition,
      isDrawing: isDrawing ?? this.isDrawing,
    );
  }

  @override
  List<Object?> get props => [points, pressPosition, isDrawing];
}
