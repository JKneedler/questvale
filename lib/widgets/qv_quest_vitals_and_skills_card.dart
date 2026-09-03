import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_state.dart';
import 'package:questvale/cubits/world_tab/questing/combat/combat_cubit.dart';
import 'package:questvale/cubits/world_tab/questing/combat/combat_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/mage_motes.dart';
import 'package:questvale/data/models/scheduled_timer.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/helpers/data_formatters.dart';
import 'package:questvale/widgets/qv_character_vitals_row.dart';
import 'package:questvale/widgets/qv_skill_button.dart';
import 'package:jk_pixel_ui/jk_pixel_ui.dart';

// Skill buttons + health/motes, as one list-item area — no gap below it
// down to the nav bar, and a QvBackground(surfaceNoBottom) shell instead of
// a bordered QvButton card: that texture's flat, cap-free bottom edge is
// what actually sells "extension of the nav bar" — a bordered button shape
// would still read as a floating card even with the gap removed. Colored
// off colorScheme.surface specifically (a new button-surface-no-bottom.png
// per theme, not the surfaceContainer default QvBackground normally uses)
// because that's the exact color NavBar itself paints its own Material
// with (see nav_bar.dart) — matching it, not just approximating it, is
// what makes the seam disappear.
//
// Now a persistent element for the *entire* quest-encounter flow (see
// QuestEncounterView, which mounts this once alongside BackgroundPage
// rather than it living inside CombatPage/CombatView) — not just live
// combat, so its content adapts around `combatState`, which is only
// non-null while a live combat encounter is actually in progress (see
// QuestEncounterView's own doc comment for how that's wired). Health/motes
// still reuses CombatStatusCard's exact CharacterVitalsRow
// (todos_overview/combat_status_card.dart) so the two read as the same
// vitals language despite the different shell, and always renders — it has
// no combat dependency. The Skills section (label/AP badge/skill-button
// row) only renders during live combat; outside that it's a plain 20px
// placeholder for now, deliberately blank rather than showing something
// non-interactive/stale — filling that in for each non-combat quest step is
// its own follow-up pass (see the Skill Cooldown UI ticket).
//
// Skill buttons stay the real CombatSkillButton (skill icon, live
// targeting/darkened/cooldown state) rather than CombatStatusCard's own
// buttons — there's a real cooldown/target flow here already. Skills sit
// above vitals here (unlike CombatStatusCard's own order), per feedback —
// they're the primary action in this card.
//
// AP sits as a small top-right badge above the skill row rather than
// between health and motes (its old spot, and CombatStatusCard's own
// _ApBadge placement) — chosen over two other options (a slim column
// back between Health/Motes, or a HUD chip up near "Encounter N / M")
// because AP is what gates tapping a skill, so pairing it visually with
// the skill row it limits reads clearer than grouping it with the
// vitals row below.
class QuestVitalsAndSkillsCard extends StatelessWidget {
  const QuestVitalsAndSkillsCard({
    super.key,
    required this.character,
    required this.mageMotes,
    required this.playerSkills,
    required this.combatState,
  });

  final Character character;
  final MageMotes? mageMotes;
  final PlayerSkills playerSkills;
  // Non-null only while a live combat encounter is actually in progress —
  // see this class's own doc comment.
  final CombatState? combatState;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final combatState = this.combatState;
    return QvBackground(
      width: double.infinity,
      type: QvBackgroundType.surfaceNoBottom,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (combatState == null)
            const SizedBox(height: 20)
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Matches every other Town Square list-item card's own
                    // leading sectionHeader label (Equipment, Weapon &
                    // Artifact, Potions) — this card didn't have one yet,
                    // and it fills what was otherwise a big blank stretch
                    // to the AP badge's left.
                    Expanded(
                      child: Text(
                        'Skills',
                        style: QvTextStyles.sectionHeader
                            .copyWith(color: colorScheme.onSurface),
                      ),
                    ),
                    QvButton(
                      height: 26,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Center(
                        child: Text(
                          '${character.actionPoints} AP',
                          style: QvTextStyles.itemTitle
                              .copyWith(color: colorScheme.secondary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (playerSkills.activeSkillSlot1 != null)
                        CombatSkillButton(
                          onTap: () => context
                              .read<CombatCubit>()
                              .onSkillButtonTap(
                                  context, playerSkills.activeSkillSlot1!),
                          skill: playerSkills.activeSkillSlot1!,
                          darkened: combatState.status ==
                                  CombatStatus.targetingSkill &&
                              combatState.targetingSkill?.id !=
                                  playerSkills.activeSkillSlot1!.id,
                          cooldownTimer: combatState.skillCooldownFor(
                              playerSkills.activeSkillSlot1!),
                        ),
                      if (playerSkills.activeSkillSlot2 != null)
                        CombatSkillButton(
                          onTap: () => context
                              .read<CombatCubit>()
                              .onSkillButtonTap(
                                  context, playerSkills.activeSkillSlot2!),
                          skill: playerSkills.activeSkillSlot2!,
                          darkened: combatState.status ==
                                  CombatStatus.targetingSkill &&
                              combatState.targetingSkill?.id !=
                                  playerSkills.activeSkillSlot2!.id,
                          cooldownTimer: combatState.skillCooldownFor(
                              playerSkills.activeSkillSlot2!),
                        ),
                      if (playerSkills.activeSkillSlot3 != null)
                        CombatSkillButton(
                          onTap: () => context
                              .read<CombatCubit>()
                              .onSkillButtonTap(
                                  context, playerSkills.activeSkillSlot3!),
                          skill: playerSkills.activeSkillSlot3!,
                          darkened: combatState.status ==
                                  CombatStatus.targetingSkill &&
                              combatState.targetingSkill?.id !=
                                  playerSkills.activeSkillSlot3!.id,
                          cooldownTimer: combatState.skillCooldownFor(
                              playerSkills.activeSkillSlot3!),
                        ),
                      if (playerSkills.activeSkillSlot4 != null)
                        CombatSkillButton(
                          onTap: () => context
                              .read<CombatCubit>()
                              .onSkillButtonTap(
                                  context, playerSkills.activeSkillSlot4!),
                          skill: playerSkills.activeSkillSlot4!,
                          darkened: combatState.status ==
                                  CombatStatus.targetingSkill &&
                              combatState.targetingSkill?.id !=
                                  playerSkills.activeSkillSlot4!.id,
                          cooldownTimer: combatState.skillCooldownFor(
                              playerSkills.activeSkillSlot4!),
                        ),
                      if (playerSkills.activeSkillSlot5 != null)
                        CombatSkillButton(
                          onTap: () => context
                              .read<CombatCubit>()
                              .onSkillButtonTap(
                                  context, playerSkills.activeSkillSlot5!),
                          skill: playerSkills.activeSkillSlot5!,
                          darkened: combatState.status ==
                                  CombatStatus.targetingSkill &&
                              combatState.targetingSkill?.id !=
                                  playerSkills.activeSkillSlot5!.id,
                          cooldownTimer: combatState.skillCooldownFor(
                              playerSkills.activeSkillSlot5!),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
          CharacterVitalsRow(character: character, mageMotes: mageMotes),
        ],
      ),
    );
  }
}

class CombatSkillButton extends StatefulWidget {
  final VoidCallback onTap;
  final BaseActiveSkill skill;
  final bool darkened;
  // Real cooldown timer for this skill (see CombatState.skillCooldowns) —
  // null means never cast yet, which reads the same as "ready" below.
  final ScheduledTimer? cooldownTimer;

  const CombatSkillButton({
    super.key,
    required this.onTap,
    required this.skill,
    required this.darkened,
    this.cooldownTimer,
  });

  @override
  State<CombatSkillButton> createState() => _CombatSkillButtonState();
}

class _CombatSkillButtonState extends State<CombatSkillButton> {
  // Ticks the cooldown countdown text down live between CombatCubit
  // reloads — display-only, same pattern as EnemyNextAttackSlice's own
  // timer (combat_page.dart). Nothing needs to be reconciled when a
  // cooldown actually expires (unlike an enemy attack timer), so this
  // never calls CombatCubit.reload() itself — the next real reload picks
  // up the DB state naturally.
  Timer? _countdownRefreshTimer;

  @override
  void initState() {
    super.initState();
    _countdownRefreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timer = widget.cooldownTimer;
    final now = DateTime.now();
    final remaining = timer != null && timer.nextTriggerAt.isAfter(now)
        ? timer.nextTriggerAt.difference(now)
        : null;
    final onCooldown = remaining != null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        QvSkillButton(
          skillIconPath: widget.skill.data.iconPath,
          // Untappable while on cooldown — targeting an unusable skill
          // would otherwise let the player pick a target and only find out
          // the cast is blocked once they hit Attack (see
          // CombatService.castSkill's onCooldown result).
          onTap: onCooldown ? () {} : widget.onTap,
          width: 65,
          height: 65,
          skillButtonColor: widget.skill.data.buttonColor,
          darkened: widget.darkened || onCooldown,
        ),
        if (onCooldown)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Text(
                  DataFormatters.formatCountdown(remaining),
                  textAlign: TextAlign.center,
                  style: QvTextStyles.itemTitle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
