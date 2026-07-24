import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/equipment.dart';

enum EquipmentGearUpStates {
  overview,
  selectingEquipment,
  selectingPotion,
  selectingArtifact;
}

class EquipmentGearUpState extends Equatable {
  final EquipmentGearUpStates currentState;
  final Equipment? equippedWeapon;
  final Equipment? equippedHelmet;
  final Equipment? equippedChestplate;
  final Equipment? equippedGloves;
  final Equipment? equippedBoots;
  final Equipment? equippedAmulet;
  final Equipment? equippedRing1;
  final Equipment? equippedRing2;
  final EquipmentSlot? selectedEquipmentSlot;
  final int? selectedRingSlot;
  final List<Equipment> inventoryEquipment;
  // Equipped Potions
  // List of available potions
  // Equipped Artifact
  // List of available artifacts

  const EquipmentGearUpState({
    this.currentState = EquipmentGearUpStates.overview,
    this.equippedWeapon,
    this.equippedHelmet,
    this.equippedChestplate,
    this.equippedGloves,
    this.equippedBoots,
    this.equippedAmulet,
    this.equippedRing1,
    this.equippedRing2,
    this.selectedEquipmentSlot,
    this.selectedRingSlot,
    this.inventoryEquipment = const [],
  });

  EquipmentGearUpState copyWith({
    EquipmentGearUpStates? currentState,
    Equipment? equippedWeapon,
    Equipment? equippedHelmet,
    Equipment? equippedChestplate,
    Equipment? equippedGloves,
    Equipment? equippedBoots,
    Equipment? equippedAmulet,
    Equipment? equippedRing1,
    Equipment? equippedRing2,
    EquipmentSlot? selectedEquipmentSlot,
    int? selectedRingSlot,
    List<Equipment>? inventoryEquipment,
  }) {
    return EquipmentGearUpState(
      currentState: currentState ?? this.currentState,
      equippedWeapon: equippedWeapon ?? this.equippedWeapon,
      equippedHelmet: equippedHelmet ?? this.equippedHelmet,
      equippedChestplate: equippedChestplate ?? this.equippedChestplate,
      equippedGloves: equippedGloves ?? this.equippedGloves,
      equippedBoots: equippedBoots ?? this.equippedBoots,
      equippedAmulet: equippedAmulet ?? this.equippedAmulet,
      equippedRing1: equippedRing1 ?? this.equippedRing1,
      equippedRing2: equippedRing2 ?? this.equippedRing2,
      selectedEquipmentSlot:
          selectedEquipmentSlot ?? this.selectedEquipmentSlot,
      selectedRingSlot: selectedRingSlot ?? this.selectedRingSlot,
      inventoryEquipment: inventoryEquipment ?? this.inventoryEquipment,
    );
  }

  @override
  List<Object?> get props => [
        currentState,
        equippedWeapon,
        equippedHelmet,
        equippedChestplate,
        equippedGloves,
        equippedBoots,
        equippedAmulet,
        equippedRing1,
        equippedRing2,
        selectedEquipmentSlot,
        selectedRingSlot,
        inventoryEquipment,
      ];
}
