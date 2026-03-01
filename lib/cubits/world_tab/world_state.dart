import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/quest.dart';

class WorldState extends Equatable {
  final Quest? quest;

  const WorldState({this.quest});

  WorldState copyWith({
    Quest? quest,
  }) {
    return WorldState(
      quest: quest ?? this.quest,
    );
  }

  @override
  List<Object?> get props => [quest];
}
