import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/character_skill.dart';

class SkillsOverviewState extends Equatable {
  final Character? character;
  final SkillType? selectedSkill;
  final int remainingSkillPoints;

  const SkillsOverviewState(
      {this.character,
      required this.selectedSkill,
      required this.remainingSkillPoints});

  SkillsOverviewState copyWith({
    Character? character,
    SkillType? selectedSkill,
    int? remainingSkillPoints,
  }) {
    return SkillsOverviewState(
      character: character ?? this.character,
      selectedSkill: selectedSkill ?? this.selectedSkill,
      remainingSkillPoints: remainingSkillPoints ?? this.remainingSkillPoints,
    );
  }

  SkillsOverviewState updateSelectedSkill(SkillType? selectSkill) {
    return SkillsOverviewState(
      character: character,
      selectedSkill: selectSkill,
      remainingSkillPoints: remainingSkillPoints,
    );
  }

  @override
  List<Object?> get props => [
        character,
        selectedSkill,
        remainingSkillPoints,
      ];
}
