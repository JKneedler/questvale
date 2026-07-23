import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/character_tab/equipment/equipment_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/equipment_repository.dart';
import 'package:sqflite/sqflite.dart';

class EquipmentCubit extends Cubit<EquipmentState> {
  Character character;
  final EquipmentSlot equipmentSlot;
  late EquipmentRepository equipmentRepository;
  late CharacterRepository characterRepository;

  EquipmentCubit(
      {required this.character,
      required this.equipmentSlot,
      required Database db})
      : super(EquipmentState()) {
    equipmentRepository = EquipmentRepository(db: db);
    characterRepository = CharacterRepository(db: db);
    loadEquipment();
  }

  Future<void> loadEquipment() async {
    final equipment = await equipmentRepository.getEquipmentByEquipmentSlot(
        equipmentSlot, character.id);
    if (!isClosed) {
      emit(state.copyWith(
          equipment: equipment,
          equippedEquipment: character.equippedForSlot(equipmentSlot)));
    }
  }

  Future<void> equipEquipment(Equipment equipment) async {
    character = character.copyWithEquippedForSlot(equipmentSlot, equipment);
    await characterRepository.updateCharacter(character);
    loadEquipment();
  }
}
