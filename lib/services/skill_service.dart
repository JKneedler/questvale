import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/stat_modifier.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/data/skills/arcane_bolt.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/data/skills/base_passive_skill.dart';
import 'package:questvale/data/skills/elemental_affinity.dart';
import 'package:questvale/data/skills/ember_burst.dart';
import 'package:questvale/data/skills/firebolt.dart';
import 'package:questvale/data/skills/frost_armor.dart';
import 'package:questvale/data/skills/frost_shard.dart';
import 'package:questvale/data/skills/hoarfrost_burst.dart';
import 'package:questvale/data/skills/ice_ward.dart';
import 'package:questvale/data/skills/mote_potency.dart';

// Both directions of a registry check between skills.json and a
// getSkillById/getPassiveSkillById switch: an id skills.json declares that
// the relevant switch has no case for, and (the rarer but still real
// direction) a case in the switch whose SkillData no longer exists — a
// stale entry left behind after a skill is renamed/removed from
// skills.json.
class SkillRegistryMismatch {
  final Set<String> missingFromRegistry;
  final Set<String> staleInRegistry;

  const SkillRegistryMismatch({
    required this.missingFromRegistry,
    required this.staleInRegistry,
  });

  bool get isEmpty => missingFromRegistry.isEmpty && staleInRegistry.isEmpty;

  @override
  String toString() =>
      'SkillService registry is out of sync with skills.json.\n'
      '${missingFromRegistry.isNotEmpty ? 'Missing a registry case for: ${missingFromRegistry.join(', ')}\n' : ''}'
      '${staleInRegistry.isNotEmpty ? 'Registered but no longer in skills.json: ${staleInRegistry.join(', ')}\n' : ''}';
}

class SkillService {
  final GameData gameData;

  // Every active-skill id getSkillById actually knows how to construct —
  // kept as an explicit set (not derived from the switch below, which code
  // can't introspect) so findRegistryMismatches can check both directions.
  // See the Skill System Foundations ticket's fail-fast-registry subtask.
  static const registeredActiveSkillIds = {
    'mage-1-arcane_bolt',
    'mage-1-firebolt',
    'mage-1-frost_shard',
    'mage-1-ember_burst',
    'mage-1-hoarfrost_burst',
    'mage-1-frost_armor',
  };

  // Same idea, for getPassiveSkillById — added alongside passives actually
  // becoming constructible (subtask 5). Mote Potency and Ice Ward are
  // registered here despite being inert (see their own doc comments) —
  // "constructible but does nothing yet" is a different, later state than
  // "not registered at all".
  static const registeredPassiveSkillIds = {
    'mage-1-mote_potency',
    'mage-1-elemental_affinity',
    'mage-1-ice_ward',
  };

  SkillService({required this.gameData}) {
    // Debug-mode only (assert bodies are stripped from release builds) —
    // a mismatch should fail loudly the moment a SkillService is
    // constructed, not the first time a player happens to tap the one
    // button that exposes it.
    assert(() {
      final activeMismatch = findRegistryMismatches(_declaredActiveSkillIds());
      if (!activeMismatch.isEmpty) throw StateError(activeMismatch.toString());
      final passiveMismatch =
          findPassiveRegistryMismatches(_declaredPassiveSkillIds());
      if (!passiveMismatch.isEmpty) {
        throw StateError(passiveMismatch.toString());
      }
      return true;
    }());
  }

  Set<String> _declaredActiveSkillIds() => gameData.skills
      .where((skill) => skill.type == SkillType.active)
      .map((skill) => skill.id)
      .toSet();

  Set<String> _declaredPassiveSkillIds() => gameData.skills
      .where((skill) => skill.type == SkillType.passive)
      .map((skill) => skill.id)
      .toSet();

  // Pure — no GameData/asset loading required, unit testable on its own
  // (see skill_service_test.dart).
  static SkillRegistryMismatch findRegistryMismatches(
      Set<String> declaredActiveSkillIds) {
    return _mismatch(declaredActiveSkillIds, registeredActiveSkillIds);
  }

  static SkillRegistryMismatch findPassiveRegistryMismatches(
      Set<String> declaredPassiveSkillIds) {
    return _mismatch(declaredPassiveSkillIds, registeredPassiveSkillIds);
  }

  static SkillRegistryMismatch _mismatch(
      Set<String> declared, Set<String> registered) {
    return SkillRegistryMismatch(
      missingFromRegistry: declared.difference(registered),
      staleInRegistry: registered.difference(declared),
    );
  }

  BaseActiveSkill getSkillById(String id) {
    final skillData = gameData.getSkillDataById(id);
    switch (skillData.id) {
      case 'mage-1-arcane_bolt':
        return ArcaneBolt(data: skillData, level: 1);
      case 'mage-1-firebolt':
        return Firebolt(data: skillData, level: 1);
      case 'mage-1-frost_shard':
        return FrostShard(data: skillData, level: 1);
      case 'mage-1-ember_burst':
        return EmberBurst(data: skillData, level: 1);
      case 'mage-1-hoarfrost_burst':
        return HoarfrostBurst(data: skillData, level: 1);
      case 'mage-1-frost_armor':
        return FrostArmor(data: skillData, level: 1);
      default:
        throw Exception('Skill not found: $id');
    }
  }

  // Passives don't have an "active skill slot" the way actives do — a
  // character just has (or doesn't have) a CharacterSkill row for one; see
  // PlayerCubit.loadCharacter for where this actually gets called
  // (once per passive CharacterSkill row) to build the stat modifiers that
  // feed PlayerStatModifierStats.
  BasePassiveSkill getPassiveSkillById(String id, {required int level}) {
    final skillData = gameData.getSkillDataById(id);
    switch (skillData.id) {
      case 'mage-1-elemental_affinity':
        return ElementalAffinity(data: skillData, level: level);
      case 'mage-1-mote_potency':
        return MotePotency(data: skillData, level: level);
      case 'mage-1-ice_ward':
        return IceWard(data: skillData, level: level);
      default:
        throw Exception('Passive skill not found: $id');
    }
  }

  // Every stat modifier `character`'s equipped/invested passive skills
  // contribute — one BasePassiveSkill.statModifiers(...) call per passive
  // CharacterSkill row, concatenated. Lives here (not duplicated inline)
  // so both PlayerCubit and TodosOverviewCubit build a PlayerCombatStats
  // for the same character from the exact same gather-and-filter logic.
  List<StatModifier> passiveModifiersFor(Character character) {
    return [
      for (final characterSkill in character.skills)
        if (gameData.getSkillDataById(characterSkill.skillId).type ==
            SkillType.passive)
          ...getPassiveSkillById(characterSkill.skillId,
                  level: characterSkill.level)
              .statModifiers(character.id),
    ];
  }
}
