import 'package:questvale/data/models/tag.dart';
import 'package:sqflite/sqflite.dart';

class TagRepository {
  final Database db;

  TagRepository({required this.db});

  Future<List<Tag>> getTags() async {
    final List<Map<String, Object?>> tagMaps = await db.query(Tag.tagTableName);

    return [
      for (final Map<String, Object?> tagMap in tagMaps) _getTagFromMap(tagMap)
    ];
  }

  Future<Tag> getTagById(String id) async {
    final tagMaps = await db.query(Tag.tagTableName,
        where: '${Tag.idColumnName} = ?', whereArgs: [id], limit: 1);
    final tagMap = tagMaps[0];
    return _getTagFromMap(tagMap);
  }

  Future<void> addTag(Tag addTag) async {
    await db.insert(Tag.tagTableName, addTag.toMap());
  }

  Future<void> updateTag(Tag updateTag) async {
    await db.update(Tag.tagTableName, updateTag.toMap(),
        where: '${Tag.idColumnName} = ?', whereArgs: [updateTag.id]);
  }

  Future<void> deleteTag(Tag deleteTag) async {
    await db.delete(Tag.tagTableName,
        where: '${Tag.idColumnName} = ?', whereArgs: [deleteTag.id]);
  }

  Tag _getTagFromMap(Map<String, Object?> map) {
    return Tag(
      id: map[Tag.idColumnName] as String,
      name: map[Tag.nameColumnName] as String,
    );
  }
}
