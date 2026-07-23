import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/character_tab/character_overview/character_overview_state.dart';
import 'package:questvale/data/models/character.dart';

class CharacterOverviewCubit extends Cubit<CharacterOverviewState> {
  CharacterOverviewCubit({required Character character})
      : super(CharacterOverviewState(equipmentSlots: [
          character.equippedWeapon,
          character.equippedHelmet,
          character.equippedChestplate,
          character.equippedGloves,
          character.equippedBoots,
          character.equippedAmulet,
          character.equippedRing1,
        ]));
}
