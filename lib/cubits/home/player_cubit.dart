import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_state.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:sqflite/sqflite.dart';

class PlayerCubit extends Cubit<PlayerState> {
  late CharacterRepository characterRepository;

  PlayerCubit({required Database db})
      : super(PlayerState(
          character: null,
        )) {
    characterRepository = CharacterRepository(db: db);
    loadCharacter();
  }

  Future<void> loadCharacter() async {
    final character = await characterRepository.getSingleCharacter();
    emit(state.copyWith(character: character));
  }
}
