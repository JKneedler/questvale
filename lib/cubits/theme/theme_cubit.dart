import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/theme/theme_state.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/helpers/constants.dart';

// Provided above MaterialApp in main.dart (where only the raw Database is
// available, not PlayerCubit/GameData) so ThemeData can be built from the
// character's persisted theme choice before HomePage's subtree exists. This
// cubit is its own source of truth for the active theme, unlike PlayerCubit
// (which other cubits reload after writing elsewhere) — setTheme both
// persists and emits in one step.
class ThemeCubit extends Cubit<ThemeState> {
  final CharacterRepository characterRepository;

  ThemeCubit({required this.characterRepository})
      : super(ThemeState(theme: APP_THEMES[DEFAULT_THEME_ID]!)) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final character = await characterRepository.getSingleCharacter();
    final theme =
        APP_THEMES[character.themeId] ?? APP_THEMES[DEFAULT_THEME_ID]!;
    if (!isClosed) {
      emit(ThemeState(theme: theme));
    }
  }

  Future<void> setTheme(String themeId) async {
    final theme = APP_THEMES[themeId];
    if (theme == null) return;
    final character = await characterRepository.getSingleCharacter();
    await characterRepository.updateCharacter(
      character.copyWith(themeId: themeId),
    );
    if (!isClosed) {
      emit(ThemeState(theme: theme));
    }
  }
}
