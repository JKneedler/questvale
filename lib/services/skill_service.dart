import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/data/skills/arcane_bolt.dart';
import 'package:questvale/data/skills/base_active_skill.dart';

class SkillService {
  final GameData gameData;

  SkillService({required this.gameData});

  BaseActiveSkill getSkillById(String id) {
    final skillData = gameData.getSkillDataById(id);
    return ArcaneBolt(data: skillData, level: 1);
  }
}
