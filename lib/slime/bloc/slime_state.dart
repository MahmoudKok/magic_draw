part of 'slime_bloc.dart';

class SlimeState extends Equatable {
  final Offset? pressPosition;
  final double deformation; // 0.0 (normal) to 1.0 (fully deformed)

  const SlimeState({
    this.pressPosition,
    this.deformation = 0.0,
  });

  SlimeState copyWith({
    Offset? pressPosition,
    double? deformation,
  }) {
    return SlimeState(
      pressPosition: pressPosition ?? this.pressPosition,
      deformation: deformation ?? this.deformation,
    );
  }

  @override
  List<Object?> get props => [pressPosition, deformation];
}
