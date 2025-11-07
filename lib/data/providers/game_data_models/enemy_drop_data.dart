import 'package:questvale/helpers/shared_enums.dart';

enum DropItemUseCase {
  material,
  alchemy,
  blacksmithing,
  gemsmithing,
  crafting,
}

class EnemyDropData {
  final String itemName;
  final int itemQuantityMin;
  final int itemQuantityMax;
  final List<DropItemUseCase> useCases;
  final Rarity rarity;
  final double dropChance;

  const EnemyDropData({
    required this.itemName,
    required this.itemQuantityMin,
    required this.itemQuantityMax,
    required this.useCases,
    required this.rarity,
    required this.dropChance,
  });

  @override
  String toString() {
    return 'EnemyDropData(itemName: $itemName, itemQuantityMin: $itemQuantityMin, itemQuantityMax: $itemQuantityMax, useCases: $useCases, rarity: $rarity, dropChance: $dropChance)';
  }

  EnemyDropData copyWith({
    String? itemName,
    int? itemQuantityMin,
    int? itemQuantityMax,
    List<DropItemUseCase>? useCases,
    Rarity? rarity,
    double? dropChance,
  }) {
    return EnemyDropData(
      itemName: itemName ?? this.itemName,
      itemQuantityMin: itemQuantityMin ?? this.itemQuantityMin,
      itemQuantityMax: itemQuantityMax ?? this.itemQuantityMax,
      useCases: useCases ?? this.useCases,
      rarity: rarity ?? this.rarity,
      dropChance: dropChance ?? this.dropChance,
    );
  }
}
