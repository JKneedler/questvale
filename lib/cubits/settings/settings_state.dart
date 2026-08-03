import 'package:equatable/equatable.dart';
import 'package:questvale/data/models/character.dart';

class SettingsState extends Equatable {
  final Character character;

  const SettingsState({required this.character});

  SettingsState copyWith({Character? character}) {
    return SettingsState(character: character ?? this.character);
  }

  @override
  List<Object?> get props => [character];
}
