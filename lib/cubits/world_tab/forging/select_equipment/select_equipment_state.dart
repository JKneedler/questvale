import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/equipment.dart';

class SelectEquipmentState extends Equatable {
  final EquipmentSlot? equipmentSlot;
  final List<Equipment> equipment;

  const SelectEquipmentState({
    this.equipmentSlot,
    this.equipment = const [],
  });

  SelectEquipmentState copyWith(
      {EquipmentSlot? equipmentSlot, List<Equipment>? equipment}) {
    return SelectEquipmentState(
        equipmentSlot: equipmentSlot ?? this.equipmentSlot,
        equipment: equipment ?? this.equipment);
  }

  @override
  List<Object?> get props => [equipmentSlot, equipment];
}
