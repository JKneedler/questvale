import 'package:jk_pixel_ui/jk_pixel_ui.dart';
import 'package:questvale/data/repositories/character_repository.dart';

/// Questvale's ThemePersistence implementation — the theme choice lives on
/// the (single) Character row, same place it always did before ThemeCubit
/// moved into jk_pixel_ui. The library itself has no idea Character or
/// CharacterRepository exist; this is the seam that used to be inline
/// inside ThemeCubit itself.
class CharacterThemePersistence implements ThemePersistence {
  final CharacterRepository characterRepository;

  const CharacterThemePersistence({required this.characterRepository});

  @override
  Future<String?> loadThemeId() async {
    final character = await characterRepository.getSingleCharacter();
    return character.themeId;
  }

  @override
  Future<void> saveThemeId(String themeId) async {
    final character = await characterRepository.getSingleCharacter();
    await characterRepository.updateCharacter(
      character.copyWith(themeId: themeId),
    );
  }
}
