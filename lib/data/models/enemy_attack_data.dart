import 'package:questvale/helpers/shared_enums.dart';

class EnemyAttackData {
  static const enemyAttackDataTableName = 'EnemyAttackData';

  static const idColumnName = 'id';
  static const enemyIdColumnName = 'enemyId';
  static const nameColumnName = 'name';
  static const damageColumnName = 'damage';
  static const damageTypeColumnName = 'damageType';
  static const cooldownColumnName = 'cooldown';
  static const weightColumnName = 'weight';

  static const createTableSQL = '''
    CREATE TABLE $enemyAttackDataTableName (
      $idColumnName VARCHAR PRIMARY KEY,
      $enemyIdColumnName VARCHAR NOT NULL,
      $nameColumnName VARCHAR NOT NULL,
      $damageColumnName INTEGER NOT NULL,
      $damageTypeColumnName INTEGER NOT NULL,
      $cooldownColumnName DOUBLE NOT NULL,
      $weightColumnName DOUBLE NOT NULL
    );
  ''';

  final String id;
  final String? enemyId;
  final String name;
  final int damage;
  final DamageType damageType;
  final double cooldown;
  final double weight;

  const EnemyAttackData({
    required this.id,
    this.enemyId,
    required this.name,
    required this.damage,
    required this.damageType,
    required this.cooldown,
    required this.weight,
  });

  Map<String, Object?> toMap(String enemyId) {
    return {
      EnemyAttackData.idColumnName: id,
      EnemyAttackData.enemyIdColumnName: enemyId,
      EnemyAttackData.nameColumnName: name,
      EnemyAttackData.damageColumnName: damage,
      EnemyAttackData.damageTypeColumnName: damageType.index,
      EnemyAttackData.cooldownColumnName: cooldown,
      EnemyAttackData.weightColumnName: weight,
    };
  }

  @override
  String toString() {
    return 'EnemyAttackData(id: $id, enemyId: $enemyId, name: $name, damage: $damage, damageType: $damageType, cooldown: $cooldown, weight: $weight)';
  }

  EnemyAttackData copyWith({
    String? name,
    int? damage,
    DamageType? damageType,
    double? cooldown,
    double? weight,
  }) {
    return EnemyAttackData(
      id: id,
      enemyId: enemyId,
      name: name ?? this.name,
      damage: damage ?? this.damage,
      damageType: damageType ?? this.damageType,
      cooldown: cooldown ?? this.cooldown,
      weight: weight ?? this.weight,
    );
  }
}
