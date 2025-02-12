import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/character_overview/character_overview_state.dart';
import 'package:questvale/data/repositories/character_repository.dart';

class CharacterOverviewCubit extends Cubit<CharacterOverviewState> {
  final CharacterRepository characterRepository;

  CharacterOverviewCubit(this.characterRepository)
      : super(CharacterOverviewState()) {
    loadCharacter();
  }

  Future<void> loadCharacter() async {
    final character = await characterRepository.getSingleCharacter();
    emit(state.copyWith(character: character));
  }
}
