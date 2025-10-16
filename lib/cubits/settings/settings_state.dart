import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/character.dart';

class SettingsState extends Equatable {
  final Character character;
  final int questsNum;
  final int encountersNum;
  final int enemiesNum;

  const SettingsState({
    required this.character,
    required this.questsNum,
    required this.encountersNum,
    required this.enemiesNum,
  });

  SettingsState copyWith({
    Character? character,
    int? questsNum,
    int? encountersNum,
    int? enemiesNum,
  }) {
    return SettingsState(
      character: character ?? this.character,
      questsNum: questsNum ?? this.questsNum,
      encountersNum: encountersNum ?? this.encountersNum,
      enemiesNum: enemiesNum ?? this.enemiesNum,
    );
  }

  @override
  List<Object?> get props => [character, questsNum, encountersNum, enemiesNum];
}
