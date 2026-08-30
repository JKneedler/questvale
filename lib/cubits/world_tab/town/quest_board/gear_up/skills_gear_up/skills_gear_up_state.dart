import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/character.dart';

class SkillsGearUpState extends Equatable {
  final Character character;
  // Which skill's detail panel is currently open, if any — at most one at
  // a time, tapping the same skill again (or a different one) toggles it.
  final String? expandedSkillId;

  const SkillsGearUpState({
    required this.character,
    this.expandedSkillId,
  });

  SkillsGearUpState copyWith({Character? character}) {
    return SkillsGearUpState(
      character: character ?? this.character,
      expandedSkillId: expandedSkillId,
    );
  }

  // Character.copyWith's `?? this.field` pattern can't null a field back
  // out — same reasoning as SettingsCubit._unequipped — so toggling the
  // expanded skill back closed needs a dedicated constructor call rather
  // than copyWith.
  SkillsGearUpState withExpandedSkillId(String? id) {
    return SkillsGearUpState(
      character: character,
      expandedSkillId: id,
    );
  }

  @override
  List<Object?> get props => [character, expandedSkillId];
}
