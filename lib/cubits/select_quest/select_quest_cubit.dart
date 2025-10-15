import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/select_quest/select_quest_state.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/enemy_data_repository.dart';
import 'package:questvale/data/repositories/quest_zone_repository.dart';

class SelectQuestCubit extends Cubit<SelectQuestState> {
  final CharacterRepository characterRepository;
  final QuestZoneRepository questZoneRepository;
  final EnemyDataRepository enemyDataRepository;

  SelectQuestCubit(this.characterRepository, this.questZoneRepository,
      this.enemyDataRepository)
      : super(const SelectQuestState()) {
    loadCharacter();
    loadQuestZones();
  }

  Future<void> toggleQuestZone(int index) async {
    final newIndex = state.selectedQuestZoneIndex == index ? -1 : index;
    emit(state.copyWith(selectedQuestZoneIndex: newIndex));
    if (newIndex != -1) {
      loadSelectedEnemies();
    }
  }

  Future<void> loadCharacter() async {
    final character = await characterRepository.getSingleCharacter();
    emit(state.copyWith(character: character));
  }

  Future<void> loadQuestZones() async {
    final questZones = await questZoneRepository.getSimpleQuestZones();
    emit(state.copyWith(questZones: questZones));
  }

  Future<void> loadSelectedEnemies() async {
    final selectedEnemies = await enemyDataRepository.getEnemiesByQuestZoneId(
        state.questZones[state.selectedQuestZoneIndex].id, true);
    final selectedQuestZone = state.questZones[state.selectedQuestZoneIndex];
    final updatedQuestZones = state.questZones
        .map((questZone) => questZone.id == selectedQuestZone.id
            ? selectedQuestZone.copyWith(enemies: selectedEnemies)
            : questZone)
        .toList();
    emit(state.copyWith(questZones: updatedQuestZones));
  }
}
