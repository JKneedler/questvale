import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/equipment.dart';

class CharacterOverviewState extends Equatable {
  final List<Equipment?> equipmentSlots;

  const CharacterOverviewState(
      {this.equipmentSlots = const [null, null, null, null, null, null, null]});

  CharacterOverviewState copyWith({
    List<Equipment?>? equipmentSlots,
  }) {
    return CharacterOverviewState(
      equipmentSlots: equipmentSlots ?? this.equipmentSlots,
    );
  }

  @override
  List<Object?> get props => [equipmentSlots];
}
