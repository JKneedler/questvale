import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/inventory_overview/inventory_overview_state.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/equipment_repository.dart';
import 'package:questvale/services/equipment_service.dart';

class InventoryOverviewCubit extends Cubit<InventoryOverviewState> {
  final CharacterRepository characterRepo;
  // temp to allow for creation of equipment
  final EquipmentRepository equipmentRepository;

  InventoryOverviewCubit(this.characterRepo, this.equipmentRepository)
      : super(InventoryOverviewState()) {
    loadCharacter();
  }

  Future<void> loadCharacter() async {
    final character = await characterRepo.getSingleCharacter();
    emit(state.copyWith(character: character));
  }

  // Temporary for testing purposes
  Future<void> createEquipmentItem() async {
    final character = state.character;
    if (character != null) {
      final equipment = EquipmentService().generateEquipment(character.level);
      if (equipment != null) {
        await equipmentRepository.insertEquipment(equipment);
        await equipmentRepository.insertInventoryEquipmentLink(
            character.inventory.id, equipment.id);
      } else {
        print('Error in generating equipment');
      }
      loadCharacter();
    }
  }

  Future<void> equipEquipment(Equipment equipment) async {
    print('Equipping : ${equipment.name}');
    final inventory = state.character?.inventory;
    if (inventory != null) {
      // Needs to assign to correct slot and un-equip item if one is already equipped
      switch (equipment.slot) {
        case EquipmentSlot.helmet:
          if (inventory.helmet != null) {
            await equipmentRepository.updateOnlyEquipment(
                inventory.helmet!.copyWith(isEquipped: false));
          }
          await equipmentRepository
              .updateOnlyEquipment(equipment.copyWith(isEquipped: true));
          await characterRepo
              .updateCharacterInventory(inventory.copyWith(helmet: equipment));
          break;
        case EquipmentSlot.body:
          if (inventory.body != null) {
            await equipmentRepository.updateOnlyEquipment(
                inventory.body!.copyWith(isEquipped: false));
          }
          await equipmentRepository
              .updateOnlyEquipment(equipment.copyWith(isEquipped: true));
          await characterRepo
              .updateCharacterInventory(inventory.copyWith(body: equipment));
          break;
        case EquipmentSlot.gloves:
          if (inventory.gloves != null) {
            await equipmentRepository.updateOnlyEquipment(
                inventory.gloves!.copyWith(isEquipped: false));
          }
          await equipmentRepository
              .updateOnlyEquipment(equipment.copyWith(isEquipped: true));
          await characterRepo
              .updateCharacterInventory(inventory.copyWith(gloves: equipment));
          break;
        case EquipmentSlot.boots:
          if (inventory.boots != null) {
            await equipmentRepository.updateOnlyEquipment(
                inventory.boots!.copyWith(isEquipped: false));
          }
          await equipmentRepository
              .updateOnlyEquipment(equipment.copyWith(isEquipped: true));
          await characterRepo
              .updateCharacterInventory(inventory.copyWith(boots: equipment));
          break;
        case EquipmentSlot.ring:
          if (inventory.ring != null) {
            await equipmentRepository.updateOnlyEquipment(
                inventory.ring!.copyWith(isEquipped: false));
          }
          await equipmentRepository
              .updateOnlyEquipment(equipment.copyWith(isEquipped: true));
          await characterRepo
              .updateCharacterInventory(inventory.copyWith(ring: equipment));
          break;
        case EquipmentSlot.amulet:
          if (inventory.amulet != null) {
            await equipmentRepository.updateOnlyEquipment(
                inventory.amulet!.copyWith(isEquipped: false));
          }
          await equipmentRepository
              .updateOnlyEquipment(equipment.copyWith(isEquipped: true));
          await characterRepo
              .updateCharacterInventory(inventory.copyWith(amulet: equipment));
          break;
        case EquipmentSlot.mainHandOnly:
          if (inventory.mainHand != null) {
            await equipmentRepository.updateOnlyEquipment(
                inventory.mainHand!.copyWith(isEquipped: false));
          }
          await equipmentRepository
              .updateOnlyEquipment(equipment.copyWith(isEquipped: true));
          await characterRepo.updateCharacterInventory(
            inventory.copyWith(
              mainHand: equipment,
              offHand: (inventory.offHand != null &&
                      inventory.offHand!.slot == EquipmentSlot.twoHanded)
                  ? null
                  : inventory.offHand,
            ),
          );
          break;
        case EquipmentSlot.offHandOnly:
          if (inventory.offHand != null) {
            await equipmentRepository.updateOnlyEquipment(
                inventory.offHand!.copyWith(isEquipped: false));
          }
          await equipmentRepository
              .updateOnlyEquipment(equipment.copyWith(isEquipped: true));
          await characterRepo.updateCharacterInventory(
            inventory.copyWith(
              mainHand: (inventory.mainHand != null &&
                      inventory.mainHand!.slot == EquipmentSlot.twoHanded)
                  ? null
                  : inventory.mainHand,
              offHand: equipment,
            ),
          );
          break;
        case EquipmentSlot.twoHanded:
          if (inventory.mainHand != null) {
            await equipmentRepository.updateOnlyEquipment(
                inventory.mainHand!.copyWith(isEquipped: false));
          }
          if (inventory.offHand != null &&
              inventory.offHand!.slot != EquipmentSlot.twoHanded) {
            await equipmentRepository.updateOnlyEquipment(
                inventory.offHand!.copyWith(isEquipped: false));
          }
          await equipmentRepository
              .updateOnlyEquipment(equipment.copyWith(isEquipped: true));
          await characterRepo.updateCharacterInventory(inventory.copyWith(
            mainHand: equipment,
            offHand: equipment,
          ));
          break;
        default:
          break;
      }
      loadCharacter();
    }
  }
}
