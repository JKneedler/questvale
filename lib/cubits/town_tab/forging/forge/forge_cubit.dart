import 'package:questvale/cubits/town_tab/forging/forge/forge_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/repositories/equipment_repository.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:sqflite/sqflite.dart';
import 'package:questvale/services/equipment_service.dart';

class ForgeCubit extends Cubit<ForgeState> {
  final String characterId;
  late CharacterRepository characterRepository;
  late EquipmentRepository equipmentRepository;
  late EquipmentService equipmentService;

  ForgeCubit({required this.characterId, required Database db})
      : super(ForgeState()) {
    characterRepository = CharacterRepository(db: db);
    equipmentRepository = EquipmentRepository(db: db);
    equipmentService = EquipmentService(db: db);
  }

  void onEquipmentSelected(Equipment equipment) {
    if (!isClosed) {
      emit(state.copyWith(
          currentLocation: ForgePageLocation.upgradeEquipment,
          selectedEquipment: equipment));
    }
  }

  void startSelectingEquipment() {
    if (!isClosed) {
      emit(state.copyWith(currentLocation: ForgePageLocation.selectEquipment));
    }
  }

  void setCurrentLocation(ForgePageLocation location) {
    if (!isClosed) {
      emit(state.copyWith(currentLocation: location));
    }
  }

  Future<void> upgradeEquipment() async {
    final character = await characterRepository.getCharacterById(characterId);
    final equipment = state.selectedEquipment;
    if (equipment != null && equipment.rarity != Rarity.legendary) {
      if (character.gold >= equipment.rarity.goldCost) {
        await equipmentService.upgradeEquipment(equipment);
        await characterRepository.updateCharacter(character.copyWith(
          gold: character.gold - equipment.rarity.goldCost,
        ));
        final newEquipment =
            await equipmentRepository.getEquipmentById(equipment.id);
        if (!isClosed) {
          emit(state.copyWith(selectedEquipment: newEquipment));
        }
      }
    }
  }
}
