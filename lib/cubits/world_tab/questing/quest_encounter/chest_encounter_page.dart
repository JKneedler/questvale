import 'package:flutter/material.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:jk_pixel_ui/jk_pixel_ui.dart';

// The "Found a chest!" banner and the tap-to-open interaction (previously
// the blinking "Open" hint + a GestureDetector wrapping this whole card)
// both moved to QuestVitalsAndSkillsCard's own _ChestFoundContent, per the
// player's request — this is purely the visual (rarity badge + chest icon)
// now, no longer interactive on its own.
class ChestEncounterPage extends StatelessWidget {
  const ChestEncounterPage(
      {super.key, required this.rarity, required this.firstPlay});
  final Rarity rarity;
  final bool firstPlay;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        QvFadeIn(
          duration: const Duration(milliseconds: 800),
          delay: const Duration(milliseconds: 1200),
          beginOpacity: 0.0,
          endOpacity: 1.0,
          child: QvCardBorder(
            height: 300,
            width: 200,
            rarityBorderAssetPath: rarity.borderAssetPath,
            bgColor: colorScheme.secondary,
            heightFactor: .98,
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                QvButton(
                  height: 40,
                  width: double.infinity,
                  buttonColor: rarityButtonColor(rarity),
                  child: Center(
                    child: Text(
                      rarity.name.toUpperCase(),
                      style: QvTextStyles.title
                          .copyWith(color: colorScheme.secondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset(
                    'images/pixel-icons/chest-closed.png',
                    scale: .1,
                    filterQuality: FilterQuality.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
