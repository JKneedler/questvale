import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/mage_motes.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/skills/base_active_skill.dart';

class PlayerSkills {
  final List<BaseActiveSkill> investedActiveSkills;
  final BaseActiveSkill? activeSkillSlot1;
  final BaseActiveSkill? activeSkillSlot2;
  final BaseActiveSkill? activeSkillSlot3;
  final BaseActiveSkill? activeSkillSlot4;
  final BaseActiveSkill? activeSkillSlot5;

  PlayerSkills({
    required this.investedActiveSkills,
    required this.activeSkillSlot1,
    required this.activeSkillSlot2,
    required this.activeSkillSlot3,
    required this.activeSkillSlot4,
    required this.activeSkillSlot5,
  });

  PlayerSkills copyWith({
    List<BaseActiveSkill>? investedActiveSkills,
    BaseActiveSkill? activeSkillSlot1,
    BaseActiveSkill? activeSkillSlot2,
    BaseActiveSkill? activeSkillSlot3,
    BaseActiveSkill? activeSkillSlot4,
    BaseActiveSkill? activeSkillSlot5,
  }) {
    return PlayerSkills(
        investedActiveSkills: investedActiveSkills ?? this.investedActiveSkills,
        activeSkillSlot1: activeSkillSlot1 ?? this.activeSkillSlot1,
        activeSkillSlot2: activeSkillSlot2 ?? this.activeSkillSlot2,
        activeSkillSlot3: activeSkillSlot3 ?? this.activeSkillSlot3,
        activeSkillSlot4: activeSkillSlot4 ?? this.activeSkillSlot4,
        activeSkillSlot5: activeSkillSlot5 ?? this.activeSkillSlot5);
  }
}

class PlayerState extends Equatable {
  final Character? character;
  final PlayerSkills? playerSkills;
  final PlayerCombatStats? playerCombatStats;
  // Null for non-Mage characters (and briefly while loading) — Warrior/Rogue
  // will get their own analogous class-resource fields once those trees
  // exist, rather than this one being repurposed for them.
  final MageMotes? mageMotes;

  const PlayerState({
    required this.character,
    required this.playerSkills,
    required this.playerCombatStats,
    this.mageMotes,
  });

  PlayerState copyWith({
    Character? character,
    PlayerSkills? playerSkills,
    PlayerCombatStats? playerCombatStats,
    MageMotes? mageMotes,
  }) {
    return PlayerState(
      character: character ?? this.character,
      playerSkills: playerSkills ?? this.playerSkills,
      playerCombatStats: playerCombatStats ?? this.playerCombatStats,
      mageMotes: mageMotes ?? this.mageMotes,
    );
  }

  @override
  List<Object?> get props => [
        character,
        playerSkills,
        playerCombatStats,
        mageMotes,
      ];
}
