import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/character_tab/character/character_state.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:sqflite/sqflite.dart';

class CharacterCubit extends Cubit<CharacterState> {
  final String characterId;
  late CharacterRepository characterRepository;

  CharacterCubit({required this.characterId, required Database db})
      : super(CharacterState()) {
    characterRepository = CharacterRepository(db: db);
  }

  void onEquipmentSlotSelected(EquipmentSlot equipmentSlot) {
    emit(state.copyWith(
        selectedEquipmentSlot: equipmentSlot,
        currentLocation: CharacterPageLocation.equipment));
  }

  void onBackButtonPressed() {
    emit(state.copyWith(
        selectedEquipmentSlot: null,
        currentLocation: CharacterPageLocation.overview));
  }
}
