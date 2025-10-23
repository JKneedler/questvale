import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/quest_encounter/quest_encounter_cubit.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/widgets/qv_blinking.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_fade_in.dart';
import 'package:questvale/widgets/qv_rarity_card_mini.dart';

class ChestEncounterPage extends StatelessWidget {
  const ChestEncounterPage(
      {super.key, required this.rarity, required this.firstPlay});
  final Rarity rarity;
  final bool firstPlay;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    print('firstPlay: $firstPlay');
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 100),
        QvFadeIn(
          duration: firstPlay
              ? const Duration(milliseconds: 600)
              : const Duration(milliseconds: 200),
          delay: firstPlay ? const Duration(milliseconds: 300) : Duration.zero,
          beginOpacity: 0.0,
          endOpacity: 1.0,
          child: QvButton(
            height: 60,
            width: 260,
            buttonColor: ButtonColor.primary,
            child: Center(
              child: Text(
                'Found a chest!',
                style: TextStyle(fontSize: 30, color: colorScheme.secondary),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            context.read<QuestEncounterCubit>().completeEncounter();
          },
          child: QvFadeIn(
            duration: firstPlay
                ? const Duration(milliseconds: 800)
                : const Duration(milliseconds: 200),
            delay: firstPlay
                ? const Duration(milliseconds: 800)
                : const Duration(milliseconds: 100),
            beginOpacity: 0.0,
            endOpacity: 1.0,
            child: QvRarityCardMini(
              height: 300,
              width: 200,
              rarity: rarity,
              bgColor: colorScheme.secondary,
              heightFactor: .98,
              padding: const EdgeInsets.only(
                  left: 10, right: 10, top: 10, bottom: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  QvButton(
                    height: 40,
                    width: double.infinity,
                    buttonColor: ButtonColor.getColor(rarity),
                    child: Center(
                      child: Text(
                        rarity.name.toUpperCase(),
                        style: TextStyle(
                            fontSize: 24, color: colorScheme.secondary),
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
                  QvBlinking(
                    isBlinking: true,
                    duration: const Duration(milliseconds: 600),
                    minOpacity: 0.3,
                    curve: Curves.easeInOut,
                    child: Text(
                      'Open',
                      style:
                          TextStyle(fontSize: 30, color: colorScheme.primary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
