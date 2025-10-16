import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/select_quest/select_quest_state.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/enemy_repository.dart';
import 'package:questvale/data/repositories/quest_zone_repository.dart';
import 'package:questvale/services/quest_service.dart';
import 'package:sqflite/sqflite.dart';

class SelectQuestCubit extends Cubit<SelectQuestState> {
  final CharacterRepository characterRepository;
  final QuestZoneRepository questZoneRepository;
  final EnemyRepository enemyDataRepository;

  SelectQuestCubit(this.characterRepository, this.questZoneRepository,
      this.enemyDataRepository)
      : super(const SelectQuestState()) {
    loadQuestZones();
  }

  Future<void> toggleQuestZone(int index) async {
    final newIndex = state.selectedQuestZoneIndex == index ? -1 : index;
    emit(state.copyWith(selectedQuestZoneIndex: newIndex));
    if (newIndex != -1) {
      loadSelectedEnemies();
    }
  }

  Future<void> loadQuestZones() async {
    final character = await characterRepository.getSingleCharacter();
    final questZones = await questZoneRepository.getAllQuestZones(false, false);
    emit(state.copyWith(character: character, questZones: questZones));
  }

  Future<void> loadSelectedEnemies() async {
    final selectedEnemies =
        await enemyDataRepository.getEnemyDatasByQuestZoneId(
            state.questZones[state.selectedQuestZoneIndex].id, true);
    final selectedQuestZone = state.questZones[state.selectedQuestZoneIndex];
    final updatedQuestZones = state.questZones
        .map((questZone) => questZone.id == selectedQuestZone.id
            ? selectedQuestZone.copyWith(enemies: selectedEnemies)
            : questZone)
        .toList();
    emit(state.copyWith(questZones: updatedQuestZones));
  }

  Future<void> beginQuest(Database db) async {
    emit(state.copyWith(questCreateState: QuestCreateStates.creating));
    final character = state.character;
    if (character == null) {
      return;
    }
    if (state.selectedQuestZoneIndex == -1 ||
        state.selectedQuestZoneIndex >= state.questZones.length) {
      return;
    }
    final questZone = state.questZones[state.selectedQuestZoneIndex];
    final success =
        await QuestService(db: db).beginQuestGeneration(character, questZone);
    emit(
      state.copyWith(
          questCreateState: success
              ? QuestCreateStates.createdSuccess
              : QuestCreateStates.createdFailed),
    );
  }
}
