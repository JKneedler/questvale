import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/equipment_gear_up/equipment_gear_up_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/repositories/equipment_repository.dart';
import 'package:sqflite/sqflite.dart';

class EquipmentGearUpCubit extends Cubit<EquipmentGearUpState> {
  final Character character;
  late EquipmentRepository equipmentRepository;

  EquipmentGearUpCubit({required Database db, required this.character})
      : super(const EquipmentGearUpState()) {
    equipmentRepository = EquipmentRepository(db: db);
    loadEquippedEquipment();
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

  void onEquippedWeaponSelected(Equipment equipment) {
    emit(state.copyWith(currentState: EquipmentGearUpStates.selectingWeapon));
    loadEquipment();
  }

  Future<void> loadEquipment() async {
    final equipments =
        await equipmentRepository.getEquipmentByCharacterId(character.id);
    List<Equipment> availableWeapons = [];
    for (var equipment in equipments) {
      if (equipment.type.slot == EquipmentSlot.weapon) {
        availableWeapons.add(equipment);
      }
    }
    if (!isClosed) {
      emit(state.copyWith(inventoryEquipment: availableWeapons));
    }
  }
}
