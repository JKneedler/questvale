import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/equipment.dart';

class EquipmentState extends Equatable {
  final List<Equipment> equipment;
  final Equipment? equippedEquipment;

  const EquipmentState({this.equipment = const [], this.equippedEquipment});

  EquipmentState copyWith({
    List<Equipment>? equipment,
    Equipment? equippedEquipment,
  }) {
    return EquipmentState(
      equipment: equipment ?? this.equipment,
      equippedEquipment: equippedEquipment ?? this.equippedEquipment,
    );
  }

  @override
  List<Object?> get props => [
        equipment,
        equippedEquipment,
      ];
}
