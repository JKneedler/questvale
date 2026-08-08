import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/data/skills/arcane_bolt.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/data/skills/ember_burst.dart';
import 'package:questvale/data/skills/firebolt.dart';
import 'package:questvale/data/skills/frost_armor.dart';
import 'package:questvale/data/skills/frost_shard.dart';
import 'package:questvale/data/skills/hoarfrost_burst.dart';

// Both directions of a registry check between skills.json and
// SkillService.getSkillById's switch: an id skills.json declares active but
// getSkillById has no case for, and (the rarer but still real direction) a
// case in the switch whose SkillData no longer exists — a stale entry left
// behind after a skill is renamed/removed from skills.json.
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
      '${missingFromRegistry.isNotEmpty ? 'Missing a getSkillById case for: ${missingFromRegistry.join(', ')}\n' : ''}'
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

  SkillService({required this.gameData}) {
    // Debug-mode only (assert bodies are stripped from release builds) —
    // a mismatch should fail loudly the moment a SkillService is
    // constructed, not the first time a player happens to tap the one
    // button that exposes it.
    assert(() {
      final mismatch = findRegistryMismatches(_declaredActiveSkillIds());
      if (!mismatch.isEmpty) throw StateError(mismatch.toString());
      return true;
    }());
  }

  Set<String> _declaredActiveSkillIds() => gameData.skills
      .where((skill) => skill.type == SkillType.active)
      .map((skill) => skill.id)
      .toSet();

  // Pure — no GameData/asset loading required, unit testable on its own
  // (see skill_service_test.dart).
  static SkillRegistryMismatch findRegistryMismatches(
      Set<String> declaredActiveSkillIds) {
    return SkillRegistryMismatch(
      missingFromRegistry:
          declaredActiveSkillIds.difference(registeredActiveSkillIds),
      staleInRegistry:
          registeredActiveSkillIds.difference(declaredActiveSkillIds),
    );
  }

  // Passive skills (Mote Potency, Elemental Affinity, Ice Ward) have no
  // BaseActiveSkill subclass and can't be looked up here — nothing equips
  // a passive into an active skill slot yet, matching how the pre-Mote
  // passives were never wired into this service either.
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
}
