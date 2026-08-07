import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/data/skills/arcane_bolt.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/data/skills/ember_burst.dart';
import 'package:questvale/data/skills/firebolt.dart';
import 'package:questvale/data/skills/frost_armor.dart';
import 'package:questvale/data/skills/frost_shard.dart';
import 'package:questvale/data/skills/hoarfrost_burst.dart';

class SkillService {
  final GameData gameData;

  SkillService({required this.gameData});

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
