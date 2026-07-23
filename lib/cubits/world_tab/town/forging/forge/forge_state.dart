import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/equipment.dart';

enum ForgePageLocation {
  upgradeEquipment,
  selectEquipment,
}

class ForgeState extends Equatable {
  final Equipment? selectedEquipment;
  final ForgePageLocation currentLocation;

  const ForgeState({
    this.selectedEquipment,
    this.currentLocation = ForgePageLocation.upgradeEquipment,
  });

  ForgeState copyWith({
    Equipment? selectedEquipment,
    ForgePageLocation? currentLocation,
  }) {
    return ForgeState(
      selectedEquipment: selectedEquipment ?? this.selectedEquipment,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }

  @override
  List<Object?> get props => [
        selectedEquipment,
        currentLocation,
      ];
}
