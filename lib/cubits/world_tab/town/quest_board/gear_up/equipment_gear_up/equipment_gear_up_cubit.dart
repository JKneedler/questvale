import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/equipment_gear_up/equipment_gear_up_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/equipment_repository.dart';
import 'package:sqflite/sqflite.dart';

class EquipmentGearUpCubit extends Cubit<EquipmentGearUpState> {
  Character character;
  late EquipmentRepository equipmentRepository;
  late CharacterRepository characterRepository;

  EquipmentGearUpCubit({required Database db, required this.character})
      : super(const EquipmentGearUpState()) {
    equipmentRepository = EquipmentRepository(db: db);
    characterRepository = CharacterRepository(db: db);
    loadEquippedEquipment();
  }

  Equipment? get selectedSlotEquippedItem {
    if (state.selectedEquipmentSlot == EquipmentSlot.ring) {
      return state.selectedRingSlot == 2
          ? character.equippedRing2
          : character.equippedRing1;
    }
    if (state.selectedEquipmentSlot == null) {
      return null;
    }
    return character.equippedForSlot(state.selectedEquipmentSlot!);
  }

  void loadEquippedEquipment() {
    emit(state.copyWith(
      equippedWeapon: character.equippedWeapon,
      equippedHelmet: character.equippedHelmet,
      equippedChestplate: character.equippedChestplate,
      equippedGloves: character.equippedGloves,
      equippedBoots: character.equippedBoots,
      equippedAmulet: character.equippedAmulet,
      equippedRing1: character.equippedRing1,
      equippedRing2: character.equippedRing2,
    ));
  }

  Future<void> onEquipmentSlotSelected(EquipmentSlot slot,
      {int? ringSlot}) async {
    emit(state.copyWith(
      currentState: EquipmentGearUpStates.selectingEquipment,
      selectedEquipmentSlot: slot,
      selectedRingSlot: ringSlot ?? 1,
    ));
    final equippedIds = character.equippedEquipmentList
        .map((equipment) => equipment.id)
        .toSet();
    final equipments = await equipmentRepository.getEquipmentByEquipmentSlot(
        slot, character.id);
    final availableEquipment = equipments
        .where((equipment) => !equippedIds.contains(equipment.id))
        .toList();
    if (!isClosed) {
      emit(state.copyWith(inventoryEquipment: availableEquipment));
    }
  }

  Future<void> equipEquipment(Equipment equipment) async {
    if (state.selectedEquipmentSlot == EquipmentSlot.ring) {
      character = state.selectedRingSlot == 2
          ? character.copyWith(equippedRing2: equipment)
          : character.copyWith(equippedRing1: equipment);
    } else if (state.selectedEquipmentSlot != null) {
      character = character.copyWithEquippedForSlot(
          state.selectedEquipmentSlot!, equipment);
    }
    await characterRepository.updateCharacter(character);
    loadEquippedEquipment();
    if (!isClosed) {
      emit(state.copyWith(currentState: EquipmentGearUpStates.overview));
    }
  }

  void onCancelSelection() {
    emit(state.copyWith(currentState: EquipmentGearUpStates.overview));
  }
}
