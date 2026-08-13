import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/character.dart';

class SkillsGearUpState extends Equatable {
  final Character character;
  // Which skill's detail panel is currently open, if any — at most one at
  // a time, tapping the same skill again (or a different one) toggles it.
  final String? expandedSkillId;
  // 1-5 while the loadout-slot picker (subtask 4) is showing instead of
  // the tier grid; null the rest of the time.
  final int? selectingLoadoutSlot;

  const SkillsGearUpState({
    required this.character,
    this.expandedSkillId,
    this.selectingLoadoutSlot,
  });

  SkillsGearUpState copyWith({Character? character}) {
    return SkillsGearUpState(
      character: character ?? this.character,
      expandedSkillId: expandedSkillId,
      selectingLoadoutSlot: selectingLoadoutSlot,
    );
  }

  // Character.copyWith's `?? this.field` pattern can't null a field back
  // out — same reasoning as SettingsCubit._unequipped — so toggling the
  // expanded skill/loadout selection back closed needs a dedicated
  // constructor call rather than copyWith.
  SkillsGearUpState withExpandedSkillId(String? id) {
    return SkillsGearUpState(
      character: character,
      expandedSkillId: id,
      selectingLoadoutSlot: selectingLoadoutSlot,
    );
  }

  SkillsGearUpState withSelectingLoadoutSlot(int? slotNumber) {
    return SkillsGearUpState(
      character: character,
      expandedSkillId: expandedSkillId,
      selectingLoadoutSlot: slotNumber,
    );
  }

  @override
  List<Object?> get props => [character, expandedSkillId, selectingLoadoutSlot];
}
