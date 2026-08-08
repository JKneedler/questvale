import 'package:questvale/data/models/status_effect_instance.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:sqflite/sqflite.dart';

class StatusEffectRepository {
  final Database db;

  StatusEffectRepository({required this.db});

  Future<StatusEffectInstance?> getInstance(
      String ownerId, StatusEffectType effectType) async {
    final maps = await db.query(
      StatusEffectInstance.statusEffectInstanceTableName,
      where:
          '${StatusEffectInstance.ownerIdColumnName} = ? AND ${StatusEffectInstance.effectTypeColumnName} = ?',
      whereArgs: [ownerId, effectType.index],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  Future<List<StatusEffectInstance>> getInstancesForOwner(
      String ownerId) async {
    final maps = await db.query(
      StatusEffectInstance.statusEffectInstanceTableName,
      where: '${StatusEffectInstance.ownerIdColumnName} = ?',
      whereArgs: [ownerId],
    );
    return maps.map(_fromMap).toList();
  }

  // Upsert — callers always pass the full post-merge/post-application
  // state (see StatusEffectService), so a plain replace is correct rather
  // than needing a separate insert-vs-update branch at every call site.
  Future<void> upsertInstance(StatusEffectInstance instance) async {
    await db.insert(
      StatusEffectInstance.statusEffectInstanceTableName,
      instance.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteInstance(
      String ownerId, StatusEffectType effectType) async {
    await db.delete(
      StatusEffectInstance.statusEffectInstanceTableName,
      where:
          '${StatusEffectInstance.ownerIdColumnName} = ? AND ${StatusEffectInstance.effectTypeColumnName} = ?',
      whereArgs: [ownerId, effectType.index],
    );
  }

  // Enemy death/encounter cleanup — clears every effect an owner carries,
  // not just one type.
  Future<void> deleteAllInstancesForOwner(String ownerId) async {
    await db.delete(
      StatusEffectInstance.statusEffectInstanceTableName,
      where: '${StatusEffectInstance.ownerIdColumnName} = ?',
      whereArgs: [ownerId],
    );
  }

  StatusEffectInstance _fromMap(Map<String, Object?> map) {
    return StatusEffectInstance(
      ownerId: map[StatusEffectInstance.ownerIdColumnName] as String,
      effectType: StatusEffectType
          .values[map[StatusEffectInstance.effectTypeColumnName] as int],
      stacks: map[StatusEffectInstance.stacksColumnName] as int,
      magnitude:
          (map[StatusEffectInstance.magnitudeColumnName] as num).toDouble(),
    );
  }
}
