import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/character/character_state.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:sqflite/sqflite.dart';

class CharacterCubit extends Cubit<CharacterState> {
  late CharacterRepository characterRepository;

  CharacterCubit({required Database db}) : super(CharacterState()) {
    characterRepository = CharacterRepository(db: db);
    loadCharacter();
  }

  Future<void> loadCharacter() async {
    final character = await characterRepository.getSingleCharacter();
    emit(state.copyWith(character: character));
  }
}
