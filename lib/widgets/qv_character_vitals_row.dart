import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/mage_motes.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/widgets/qv_bar.dart';
import 'package:questvale/widgets/qv_mote_display.dart';
import 'package:questvale/widgets/qv_text_styles.dart';

/// Health bar / class-resource block, leaning toward its container's outer
/// edges. Originally built for the Todo tab's pinned CombatStatusCard
/// (todos_overview/combat_status_card.dart) and pulled out here so the
/// Combat page's own vitals+skills card can reuse the exact same widget —
/// per feedback, both should read as the same "health left, resource
/// right" language rather than two independently-styled copies that could
/// drift apart. Health comes straight off the loaded Character; the
/// class-resource side is class-conditional (Motes for Mage today;
/// Warrior's Rage/Rogue's Focus will slot in here the same way once those
/// trees exist — see MageMotes' doc comment for why each gets its own
/// model instead of a shared one).
class CharacterVitalsRow extends StatelessWidget {
  final Character character;
  final MageMotes? mageMotes;
  const CharacterVitalsRow({super.key, required this.character, this.mageMotes});

  @override
  Widget build(BuildContext context) {
    // Watched directly rather than threaded down from a distant ancestor —
    // same pattern combat_page.dart's TargetEnemySkillBox already uses.
    // maxHealth lives on PlayerCombatStats (not Character — see the Skill
    // System Foundations ticket), since it's the only place gear's Health
    // stat modifier is actually consulted.
    final playerCombatStats = context.watch<PlayerCubit>().state.playerCombatStats;
    if (playerCombatStats == null) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${character.currentHealth} / ${playerCombatStats.maxHealth}',
                    style: QvTextStyles.sectionHeader.copyWith(color: HEALTH_COLOR),
                  ),
                  Text(
                    'HP',
                    style: QvTextStyles.sectionHeader.copyWith(color: HEALTH_COLOR),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              QvBar(
                currentValue: character.currentHealth,
                maxValue: playerCombatStats.maxHealth,
                resource: QvBarResource.health,
                size: QvBarSize.mini,
                height: 20,
                child: const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        if (character.characterClass == CharacterClass.mage &&
            mageMotes != null) ...[
          const SizedBox(width: 8),
          Expanded(child: QvMoteDisplay(motes: mageMotes!)),
        ],
      ],
    );
  }
}
