import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/inventory.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/data/models/quest.dart';
import 'package:questvale/data/models/character_skill.dart';
import 'package:questvale/data/models/character_tag.dart';
import 'package:questvale/data/repositories/character_skill_repository.dart';
import 'package:questvale/data/repositories/equipment_repository.dart';
import 'package:sqflite/sqflite.dart';

class CharacterRepository {
  final Database db;

  late EquipmentRepository equipmentRepo;
  late CharacterSkillRepository skillRepository;

  CharacterRepository({required this.db}) {
    equipmentRepo = EquipmentRepository(db: db);
    skillRepository = CharacterSkillRepository(db: db);
  }

  // GET the one existing character -- temporary
  Future<Character> getSingleCharacter() async {
    final characterMaps = await db.query(
      Character.characterTableName,
      limit: 1,
    );
    final character = await _getCharacterFromMap(characterMaps[0]);
    return character;
  }

  // GET by id
  Future<Character> getCharacterById(String id) async {
    final characterMaps = await db.query(
      Character.characterTableName,
      where: '${Character.idColumnName} = ?',
      whereArgs: [id],
      limit: 1,
    );
    final character = await _getCharacterFromMap(characterMaps[0]);
    return character;
  }

  // UPDATE by character
  Future<Character> updateCharacter(Character updateCharacter) async {
    await db.update(
      Character.characterTableName,
      updateCharacter.toMap(),
      where: '${Character.idColumnName} = ?',
      whereArgs: [updateCharacter.id],
    );
    final character = await getCharacterById(updateCharacter.id);
    return character;
  }

  // INSERT character
  Future<void> insertCharacter(Character insertCharacter) async {
    await db.insert(
      Inventory.inventoryTableName,
      insertCharacter.inventory.toMap(),
    );
    await db.insert(
      Character.characterTableName,
      insertCharacter.toMap(),
    );
  }

  Future<void> updateCharacterInventory(Inventory updateInventory) async {
    await db.update(
      Inventory.inventoryTableName,
      updateInventory.toMap(),
      where: '${Inventory.idColumnName} = ?',
      whereArgs: [updateInventory.id],
    );
  }

  // CHARACTER TAGS METHODS
  Future<List<CharacterTag>> getCharacterTags(String characterId) async {
    final tagMaps = await db.query(
      CharacterTag.characterTagTableName,
      where: '${CharacterTag.characterIdColumnName} = ?',
      whereArgs: [characterId],
    );

    return [
      for (final tagMap in tagMaps)
        CharacterTag(
          id: tagMap[CharacterTag.idColumnName] as String,
          characterId: tagMap[CharacterTag.characterIdColumnName] as String,
          name: tagMap[CharacterTag.nameColumnName] as String,
          colorIndex: tagMap[CharacterTag.colorIndexColumnName] as int,
          iconIndex: tagMap[CharacterTag.iconIndexColumnName] as int,
        ),
    ];
  }

  Future<void> createCharacterTag(CharacterTag tag) async {
    await db.insert(
      CharacterTag.characterTagTableName,
      tag.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCharacterTag(CharacterTag tag) async {
    await db.update(
      CharacterTag.characterTagTableName,
      tag.toMap(),
      where: '${CharacterTag.idColumnName} = ?',
      whereArgs: [tag.id],
    );
  }

  Future<void> deleteCharacterTag(CharacterTag tag) async {
    await db.delete(
      CharacterTag.characterTagTableName,
      where: '${CharacterTag.idColumnName} = ?',
      whereArgs: [tag.id],
    );
  }

  Future<void> printCharacters() async {
    final characterMaps = await db.query(Character.characterTableName);
    print(characterMaps);
  }

  Future<void> printQuests() async {
    final questMaps = await db.query(Quest.questTableName);
    print(questMaps);
  }

  Future<void> printEquipment() async {
    final equipmentMaps = await db.query(Equipment.equipmentTableName);
    print(equipmentMaps);
  }

  Future<Character> _getCharacterFromMap(Map<String, Object?> map) async {
    final Inventory inventory = await _getCharacterInventory(
        map[Character.inventoryColumnName] as String);
    final List<CharacterSkill> skills =
        await _getSkills(map[Character.idColumnName] as String);
    final character = Character(
      id: map[Character.idColumnName] as String,
      name: map[Character.nameColumnName] as String,
      characterClass:
          CharacterClass.values[map[Character.characterClassColumnName] as int],
      level: map[Character.levelColumnName] as int,
      currentExp: map[Character.currentExpColumnName] as int,
      inventory: inventory,
      currentHealth: map[Character.currentHealthColumnName] as int,
      currentMana: map[Character.currentManaColumnName] as int,
      attacksRemaining: map[Character.attacksRemainingColumnName] as int,
      skills: skills,
    );
    return character;
  }

  Future<Inventory> _getCharacterInventory(String inventoryId) async {
    List<Equipment> equipments =
        await equipmentRepo.getByInventoryId(inventoryId);
    final inventoryMaps = await db.query(
      Inventory.inventoryTableName,
      where: '${Inventory.idColumnName} = ?',
      whereArgs: [inventoryId],
    );
    final map = inventoryMaps[0];
    final helmet = equipments
        .where((equipment) =>
            equipment.isEquipped &&
            equipment.slot == EquipmentSlot.helmet &&
            equipment.id == map[Inventory.helmetColumnName] as String?)
        .toList();
    final body = equipments
        .where((equipment) =>
            equipment.isEquipped &&
            equipment.slot == EquipmentSlot.body &&
            equipment.id == map[Inventory.bodyColumnName] as String?)
        .toList();
    final gloves = equipments
        .where((equipment) =>
            equipment.isEquipped &&
            equipment.slot == EquipmentSlot.gloves &&
            equipment.id == map[Inventory.glovesColumnName] as String?)
        .toList();
    final boots = equipments
        .where((equipment) =>
            equipment.isEquipped &&
            equipment.slot == EquipmentSlot.boots &&
            equipment.id == map[Inventory.bootsColumnName] as String?)
        .toList();
    final ring = equipments
        .where((equipment) =>
            equipment.isEquipped &&
            equipment.slot == EquipmentSlot.ring &&
            equipment.id == map[Inventory.ringColumnName] as String?)
        .toList();
    final amulet = equipments
        .where((equipment) =>
            equipment.isEquipped &&
            equipment.slot == EquipmentSlot.amulet &&
            equipment.id == map[Inventory.amuletColumnName])
        .toList();
    final mainHand = equipments
        .where((equipment) =>
            equipment.isEquipped &&
            [EquipmentSlot.mainHandOnly, EquipmentSlot.twoHanded]
                .contains(equipment.slot) &&
            equipment.id == map[Inventory.mainHandColumnName] as String?)
        .toList();
    List<Equipment> offHand;
    if (mainHand.isNotEmpty && mainHand[0].slot == EquipmentSlot.twoHanded) {
      offHand = [mainHand[0]];
    } else {
      offHand = equipments
          .where((equipment) =>
              equipment.isEquipped &&
              [EquipmentSlot.offHandOnly].contains(equipment.slot) &&
              equipment.id == map[Inventory.offHandColumnName] as String?)
          .toList();
    }

    return Inventory(
      id: map[Inventory.idColumnName] as String,
      gold: map[Inventory.goldColumnName] as int,
      equipments: equipments,
      helmet: helmet.isNotEmpty ? helmet[0] : null,
      body: body.isNotEmpty ? body[0] : null,
      gloves: gloves.isNotEmpty ? gloves[0] : null,
      boots: boots.isNotEmpty ? boots[0] : null,
      ring: ring.isNotEmpty ? ring[0] : null,
      amulet: amulet.isNotEmpty ? amulet[0] : null,
      mainHand: mainHand.isNotEmpty ? mainHand[0] : null,
      offHand: offHand.isNotEmpty ? offHand[0] : null,
    );
  }

  Future<List<CharacterSkill>> _getSkills(String charId) async {
    final skills = await skillRepository.getByCharacterId(charId);
    return skills;
  }
}
