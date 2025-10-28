import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/character_tab/character_overview/character_overview_state.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/repositories/equipment_repository.dart';
import 'package:sqflite/sqflite.dart';

class CharacterOverviewCubit extends Cubit<CharacterOverviewState> {
  final String characterId;
  late EquipmentRepository equipmentRepository;

  CharacterOverviewCubit({required this.characterId, required Database db})
      : super(CharacterOverviewState()) {
    equipmentRepository = EquipmentRepository(db: db);
    loadEquipment();
  }

  Future<void> loadEquipment() async {
    final equipment = await equipmentRepository
        .getEquippedEquipmentByCharacterId(characterId);
    List<Equipment?> equipmentSlots =
        List.filled(EquipmentSlot.values.length, null);
    for (var equipment in equipment) {
      equipmentSlots[equipment.type.slot.index] = equipment;
    }

    if (!isClosed) {
      emit(state.copyWith(
        equipmentSlots: equipmentSlots,
      ));
    }
  }
}
