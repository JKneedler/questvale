import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/quest_overview/quest_overview_state.dart';
import 'package:questvale/data/models/quest.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/enemy_repository.dart';
import 'package:questvale/data/repositories/quest_repository.dart';
import 'package:questvale/data/repositories/quest_room_repository.dart';
import 'package:questvale/services/quest_service.dart';

class QuestOverviewCubit extends Cubit<QuestOverviewState> {
  final CharacterRepository characterRepository;
  final QuestRepository questRepository;
  final QuestRoomRepository questRoomRepository;
  final EnemyRepository enemyRepository;

  QuestOverviewCubit(this.characterRepository, this.questRepository,
      this.questRoomRepository, this.enemyRepository)
      : super(QuestOverviewState()) {
    init();
  }

  Future<void> init() async {
    await load();
  }

  Future<void> load() async {
    final character = await characterRepository.getSingleCharacter();
    final quest =
        await questRepository.getActiveQuestByCharacterId(character.id);
    if (quest != null) {
      emit(state.copyWith(quest: quest, character: character));
    } else {
      emit(state.copyWith(character: character, quest: null));
    }
  }

  Future<void> loadQuest() async {
    final characterId = state.character?.id;
    if (characterId != null) {
      final quest =
          await questRepository.getActiveQuestByCharacterId(characterId);
      print(quest ?? 'no quest found');
      emit(state.copyWith(quest: quest));
    }
  }

  Future<void> createQuest() async {
    final character = state.character;
    if (character != null) {
      Quest newQuest = QuestService().generateQuest(character);
      await questRepository.addQuest(newQuest.copyWith(isActive: true));
      load();
    }
  }

  Future<void> attackEnemy(int index) async {
    print('Attacking');
    if (state.character!.attacksRemaining > 0) {
      final enemy = state.quest!.currentRoom.enemies[index];
      final enemyHealth = enemy.currentHealth - state.character!.attackDamage;
      await enemyRepository
          .updateEnemy(enemy.copyWith(currentHealth: enemyHealth));
    } else {
      print('No attacks remaining');
    }
    await load();
  }

  Future<void> nextRoom() async {
    final currentRoom = state.quest!.currentRoom;
    await questRoomRepository
        .updateQuestRoom(currentRoom.copyWith(isCompleted: true));
    load();
  }

  Future<void> completeQuest() async {
    await questRepository.updateQuest(state.quest!.copyWith(isActive: false));
    load();
  }
}
