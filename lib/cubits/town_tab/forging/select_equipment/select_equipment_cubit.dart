import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/town_tab/forging/select_equipment/select_equipment_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/repositories/equipment_repository.dart';
import 'package:sqflite/sqflite.dart';

class SelectEquipmentCubit extends Cubit<SelectEquipmentState> {
  late EquipmentRepository equipmentRepository;
  final Character character;

  SelectEquipmentCubit({required this.character, required Database db})
      : super(SelectEquipmentState()) {
    equipmentRepository = EquipmentRepository(db: db);
    loadEquipment();
  }

  Future<void> loadEquipment() async {
    if (state.equipmentSlot == null) {
      return;
    }
    final equipment = await equipmentRepository.getEquipmentByEquipmentSlot(
        state.equipmentSlot!, character.id);
    if (!isClosed) {
      emit(state.copyWith(equipment: equipment));
    }
  }

  void onEquipmentSlotSelected(EquipmentSlot equipmentSlot) {
    if (!isClosed) {
      emit(state.copyWith(equipmentSlot: equipmentSlot));
    }
    loadEquipment();
  }

  void onClearEquipmentSlot() {
    if (!isClosed) {
      emit(SelectEquipmentState());
    }
  }
}
