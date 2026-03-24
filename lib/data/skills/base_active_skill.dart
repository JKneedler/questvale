import 'package:questvale/data/providers/game_data_models/skill_data.dart';

abstract class BaseActiveSkill {
  final String id;
  final SkillData data;
  final int level;

  BaseActiveSkill({
    required this.id,
    required this.data,
    required this.level,
  });

  String get description;
}
