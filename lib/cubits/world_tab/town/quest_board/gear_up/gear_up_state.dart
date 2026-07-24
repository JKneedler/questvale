import 'package:equatable/equatable.dart';

class GearUpState extends Equatable {
  final int gearTabIndex;

  const GearUpState({this.gearTabIndex = 0});

  GearUpState copyWith({
    int? gearTabIndex,
  }) {
    return GearUpState(gearTabIndex: gearTabIndex ?? this.gearTabIndex);
  }

  @override
  List<Object?> get props => [gearTabIndex];
}
