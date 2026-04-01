import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/data/skills/arcane_bolt.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/data/skills/elemental_surge.dart';

class SkillService {
  final GameData gameData;

  SkillService({required this.gameData});

  BaseActiveSkill getSkillById(String id) {
    final skillData = gameData.getSkillDataById(id);
    if (skillData.id == 'mage-1-arcane_bolt') {
      return ArcaneBolt(data: skillData, level: 1);
    } else if (skillData.id == 'mage-1-elemental_surge') {
      return ElementalSurge(data: skillData, level: 1);
    }
    throw Exception('Skill not found: $id');
  }
}
