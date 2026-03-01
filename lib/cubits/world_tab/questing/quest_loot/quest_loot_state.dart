import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/equipment.dart';

class QuestLootState extends Equatable {
  final int gold;
  final int xp;
  final List<Equipment> equipment;
  const QuestLootState(
      {required this.gold, required this.xp, required this.equipment});

  QuestLootState copyWith({
    int? gold,
    int? xp,
    List<Equipment>? equipment,
  }) {
    return QuestLootState(
      gold: gold ?? this.gold,
      xp: xp ?? this.xp,
      equipment: equipment ?? this.equipment,
    );
  }

  @override
  List<Object?> get props => [gold, xp, equipment];
}
