import 'package:questvale/data/providers/game_data_models/skill_data.dart';

abstract class BasePassiveSkill {
  final String id;
  final SkillData data;
  final int level;

  BasePassiveSkill({
    required this.id,
    required this.data,
    required this.level,
  });

  String get description;
}
