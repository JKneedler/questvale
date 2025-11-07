import 'package:questvale/helpers/shared_enums.dart';

class EnemyAttackData {
  final String name;
  final int damage;
  final DamageType damageType;
  final double cooldown;
  final double weight;

  const EnemyAttackData({
    required this.name,
    required this.damage,
    required this.damageType,
    required this.cooldown,
    required this.weight,
  });

  @override
  String toString() {
    return 'EnemyAttackData(name: $name, damage: $damage, damageType: $damageType, cooldown: $cooldown, weight: $weight)';
  }

  EnemyAttackData copyWith({
    String? name,
    int? damage,
    DamageType? damageType,
    double? cooldown,
    double? weight,
  }) {
    return EnemyAttackData(
      name: name ?? this.name,
      damage: damage ?? this.damage,
      damageType: damageType ?? this.damageType,
      cooldown: cooldown ?? this.cooldown,
      weight: weight ?? this.weight,
    );
  }
}
