import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_text_styles.dart';

// Only Mage has a character portrait today (images/characters/mage.png) —
// same "nothing else exists yet" reality combat_page.dart's own hardcoded
// reference to it already lives with. Falls back to the same image rather
// than throwing for a class that can't actually be created yet.
String _characterImagePath(CharacterClass characterClass) {
  switch (characterClass) {
    case CharacterClass.mage:
    case CharacterClass.warrior:
    case CharacterClass.rogue:
      return 'images/characters/mage.png';
  }
}

String _capitalize(String value) =>
    value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

// Sits at the top of Town Square's list — a quick, glanceable read of the
// character (portrait, level/class, core combat stats) rather than a
// detailed sheet, since this page is visited briefly and with intent
// between quests. See the Combat & Questing Redesign ticket.
class CharacterStatsCard extends StatelessWidget {
  const CharacterStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final playerState = context.watch<PlayerCubit>().state;
    final character = playerState.character;
    final playerCombatStats = playerState.playerCombatStats;
    if (character == null || playerCombatStats == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: QvButton(
        buttonColor: ButtonColor.surfaceContainer,
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              _characterImagePath(character.characterClass),
              width: 72,
              height: 72,
              filterQuality: FilterQuality.none,
              scale: .1,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    character.name,
                    style: QvTextStyles.subheading.copyWith(color: colorScheme.onSurface),
                  ),
                  Text(
                    'Lv ${character.level} ${_capitalize(character.characterClass.name)}',
                    style: QvTextStyles.body
                        .copyWith(color: colorScheme.onSurface.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 14,
                    runSpacing: 4,
                    children: [
                      _StatChip(
                          label: 'ATK',
                          value: playerCombatStats.physicalAttackPower
                              .round()
                              .toString()),
                      _StatChip(
                          label: 'DEF',
                          value: playerCombatStats.armor.round().toString()),
                      _StatChip(
                          label: 'HP', value: '${playerCombatStats.maxHealth}'),
                      _StatChip(
                          label: 'CRIT',
                          value:
                              '${(playerCombatStats.critChance * 100).round()}%'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        Text(
          value,
          style: QvTextStyles.caption.copyWith(color: colorScheme.onSurface),
        ),
      ],
    );
  }
}
