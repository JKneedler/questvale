import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/quest_overview/quest_overview_state.dart';
import 'package:questvale/data/models/quest.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/combatant_repository.dart';
import 'package:questvale/data/repositories/quest_repository.dart';
import 'package:questvale/data/repositories/quest_room_repository.dart';
import 'package:questvale/services/quest_service.dart';

class QuestOverviewCubit extends Cubit<QuestOverviewState> {
  final CharacterRepository characterRepository;
  final QuestRepository questRepository;
  final QuestRoomRepository questRoomRepository;
  final CombatantRepository combatantRepository;

  QuestOverviewCubit(this.characterRepository, this.questRepository,
      this.questRoomRepository, this.combatantRepository)
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
      emit(state.copyWith(character: character));
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

  Future<void> attackCombatant() async {
    print('Attacking');
    if (state.character!.attacksRemaining > 0) {
      final combatant =
          state.quest!.rooms[state.quest!.currentRoomNumber].combatants[0];
      // TODO move this to db
      final characterDamage = 5;
      final combatantHealth = combatant.currentHealth - characterDamage;
      await combatantRepository
          .updateCombatant(combatant.copyWith(currentHealth: combatantHealth));
      await load();
    } else {
      print('No attacks remaining');
    }
  }
}
