import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/equipment.dart';

enum CharacterPageLocation {
  overview,
  equipment,
  skills,
  potions,
  artifacts,
  materials,
  combatStats;
}

class CharacterState extends Equatable {
  final CharacterPageLocation currentLocation;
  final EquipmentSlot? selectedEquipmentSlot;

  const CharacterState(
      {this.currentLocation = CharacterPageLocation.overview,
      this.selectedEquipmentSlot});

  CharacterState copyWith({
    CharacterPageLocation? currentLocation,
    EquipmentSlot? selectedEquipmentSlot,
  }) {
    return CharacterState(
      currentLocation: currentLocation ?? this.currentLocation,
      selectedEquipmentSlot:
          selectedEquipmentSlot ?? this.selectedEquipmentSlot,
    );
  }

  @override
  List<Object?> get props => [currentLocation, selectedEquipmentSlot];
}
