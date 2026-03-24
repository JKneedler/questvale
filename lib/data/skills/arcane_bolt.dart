import 'package:questvale/data/skills/base_active_skill.dart';

class ArcaneBolt extends BaseActiveSkill {
  ArcaneBolt({
    super.id = 'mage-1-arcane_bolt',
    required super.data,
    required super.level,
  });

  @override
  String get description =>
      data.description.replaceAll('x%', '${data.primaryBaseValue}%');
}
