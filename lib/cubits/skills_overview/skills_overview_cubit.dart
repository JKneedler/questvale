import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/skills_overview/skills_overview_state.dart';
import 'package:questvale/data/models/character_skill.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/character_skill_repository.dart';
import 'package:uuid/uuid.dart';

class SkillsOverviewCubit extends Cubit<SkillsOverviewState> {
  final CharacterRepository characterRepository;
  final CharacterSkillRepository skillRepository;

  SkillsOverviewCubit(this.characterRepository, this.skillRepository)
      : super(SkillsOverviewState(
          selectedSkill: null,
          remainingSkillPoints: 0,
        )) {
    loadCharacter();
  }

  Future<void> loadCharacter() async {
    final character = await characterRepository.getSingleCharacter();

    int skillPoints = character.level;
    for (CharacterSkill skill in character.skills) skillPoints -= skill.level;

    emit(state.copyWith(
      character: character,
      remainingSkillPoints: skillPoints,
    ));
  }

  void selectSkill(SkillType selectSkill) {
    if (state.selectedSkill != null && state.selectedSkill == selectSkill) {
      emit(state.updateSelectedSkill(null));
    } else {
      emit(state.updateSelectedSkill(selectSkill));
    }
  }

  Future<void> upgradeSkill(SkillType type) async {
    final character = state.character;
    if (character != null) {
      if (state.remainingSkillPoints > 0) {
        if (character.skills.any((element) => element.type == type)) {
          final skill =
              character.skills.firstWhere((element) => element.type == type);
          await skillRepository
              .updateSkill(skill.copyWith(level: skill.level + 1));
        } else {
          await skillRepository.insertSkill(CharacterSkill(
            id: Uuid().v1(),
            characterId: character.id,
            type: type,
            level: 1,
          ));
        }
        loadCharacter();
      }
    }
  }

  Future<void> resetSkills() async {
    final character = state.character;
    if (character != null) {
      for (CharacterSkill skill in character.skills) {
        await skillRepository.deleteSkill(skill);
      }
      loadCharacter();
    }
  }
}
