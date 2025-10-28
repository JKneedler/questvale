import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/character_tab/equipment/equipment_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/repositories/equipment_repository.dart';
import 'package:sqflite/sqflite.dart';

class EquipmentCubit extends Cubit<EquipmentState> {
  final Character character;
  final EquipmentSlot equipmentSlot;
  late EquipmentRepository equipmentRepository;

  EquipmentCubit(
      {required this.character,
      required this.equipmentSlot,
      required Database db})
      : super(EquipmentState()) {
    equipmentRepository = EquipmentRepository(db: db);
    loadEquipment();
  }

  Future<void> loadEquipment() async {
    final equipment = await equipmentRepository.getEquipmentByEquipmentSlot(
        equipmentSlot, character.id);
    print('equipment: $equipment');
    Equipment? equippedEquipment;
    for (var equipment in equipment) {
      if (equipment.isEquipped) {
        equippedEquipment = equipment;
        break;
      }
    }
    if (!isClosed) {
      emit(state.copyWith(
          equipment: equipment, equippedEquipment: equippedEquipment));
    }
  }

  Future<void> equipEquipment(Equipment equipment) async {
    if (state.equippedEquipment != null) {
      await equipmentRepository.updateEquipment(
          state.equippedEquipment!.copyWith(isEquipped: false));
    }
    await equipmentRepository
        .updateEquipment(equipment.copyWith(isEquipped: true));
    loadEquipment();
  }
}
