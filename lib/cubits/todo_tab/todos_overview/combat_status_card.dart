import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_cubit.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/scheduled_timer.dart';
import 'package:questvale/data/providers/game_data_models/enemy_data.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/helpers/data_formatters.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/services/leveling_service.dart';
import 'package:questvale/widgets/qv_character_vitals_row.dart';
import 'package:jk_pixel_ui/jk_pixel_ui.dart';

// Scaffold for the character/combat status block pinned above the todo
// list. XP (level/currentExp), health/AP/mana, in-combat enemy state, enemy
// attack countdowns, and skill cooldowns all read real data from
// TodosOverviewCubit/PlayerCubit. Leveling itself is real now (see
// LevelingService) — completing an encounter can roll currentExp into a
// level-up and grant Skill Points — but the curve it rolls against is still
// the same placeholder `level * 100` the exp-needed denominator below
// always used; real curve design is separate balance work.
class CombatStatusCard extends StatefulWidget {
  const CombatStatusCard({super.key});

  @override
  State<CombatStatusCard> createState() => _CombatStatusCardState();
}

class _CombatStatusCardState extends State<CombatStatusCard> {
  Timer? _countdownRefreshTimer;

  @override
  void initState() {
    super.initState();
    // Recomputes nextTriggerAt - now() every second, so the countdown
    // visibly ticks down rather than jumping in chunks — purely
    // presentational when nothing has expired yet. But once an enemy's
    // timer has actually reached zero, ticking the *display* forever isn't
    // enough: nothing else re-triggers reconciliation, so the countdown
    // would otherwise freeze at 00:00 indefinitely instead of resolving
    // the attack and arming the next one. Route through the real reload in
    // that case.
    _countdownRefreshTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;
        final cubit = context.read<TodosOverviewCubit>();
        final now = DateTime.now();
        final hasExpiredAttackTimer =
            cubit.state.activeEncounter?.enemies.any((enemy) {
                  final timer = cubit.state.attackTimerFor(enemy);
                  return timer != null && !timer.nextTriggerAt.isAfter(now);
                }) ??
                false;
        if (hasExpiredAttackTimer) {
          cubit.loadCharacter();
        } else {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _countdownRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodosOverviewCubit, TodosOverviewState>(
      builder: (context, state) {
        final character = state.character;
        if (character == null) return const SizedBox.shrink();
        final isExpanded = character.combatStatusCardExpanded;
        final playerSkills = context.watch<PlayerCubit>().state.playerSkills;
        final equippedSkills = [
          playerSkills?.activeSkillSlot1,
          playerSkills?.activeSkillSlot2,
          playerSkills?.activeSkillSlot3,
          playerSkills?.activeSkillSlot4,
          playerSkills?.activeSkillSlot5,
        ].whereType<BaseActiveSkill>().toList();

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: QvButton(
            buttonColor: ButtonColor.surfaceContainer,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tapping the exp/vitals block toggles the collapsed state —
                // scoped to just this GestureDetector (not the whole card)
                // so tapping a skill button or enemy block below doesn't
                // also collapse the card.
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context
                      .read<TodosOverviewCubit>()
                      .toggleCombatStatusCardExpanded(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _ApBadge(character: character),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ExperienceBar(
                                character: character, isExpanded: isExpanded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      CharacterVitalsRow(
                          character: character, mageMotes: state.mageMotes),
                    ],
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: !isExpanded
                      ? const SizedBox(width: double.infinity)
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 6),
                            const _SectionHeader(label: 'Skills'),
                            const SizedBox(height: 4),
                            _SkillCooldownRow(
                              skills: equippedSkills,
                              skillCooldowns: state.skillCooldowns,
                            ),
                            const SizedBox(height: 6),
                            const _SectionHeader(label: 'Enemies'),
                            const SizedBox(height: 4),
                            _CombatEnemiesSection(state: state),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Centered section label with divider lines extending to either side —
// separates the XP/vitals block from Skills, and Skills from Enemies.
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = colorScheme.onSurface.withValues(alpha: 0.15);
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: dividerColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: QvTextStyles.itemTitle
                .copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
        ),
        Expanded(child: Container(height: 1, color: dividerColor)),
      ],
    );
  }
}

// Row 0 — full-width XP bar. Level and currentExp are real, and now
// actually roll over into a level-up (see LevelingService) instead of
// growing unbounded. The exp-needed-for-next-level denominator itself is
// still a placeholder curve — reads LevelingService.expForLevel rather than
// re-hardcoding it here, so this can't drift from what actually gates the
// next level-up.
class _ExperienceBar extends StatelessWidget {
  final Character character;
  final bool isExpanded;
  const _ExperienceBar({required this.character, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    final expForNextLevel = LevelingService.expForLevel(character.level);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LVL ${character.level}',
              style: QvTextStyles.sectionTitle
                  .copyWith(color: EXP_COLOR, fontWeight: FontWeight.w900),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${character.currentExp} / $expForNextLevel',
                  style: QvTextStyles.sectionHeader
                      .copyWith(color: EXP_COLOR, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 2),
                Icon(
                  isExpanded
                      ? Symbols.keyboard_arrow_up
                      : Symbols.keyboard_arrow_down,
                  color: EXP_COLOR,
                  size: 22,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 2),
        QvBar(
          currentValue: character.currentExp,
          maxValue: expForNextLevel,
          resource: QvBarResource.exp,
          size: QvBarSize.mini,
          height: 20,
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// AP badge — now sits to the left of the level/exp block instead of
// between the health and mana bars.
class _ApBadge extends StatelessWidget {
  final Character character;
  const _ApBadge({required this.character});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return QvInsetBackground(
      type: QvInsetBackgroundType.surface,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${character.actionPoints}',
            style: QvTextStyles.banner.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          Text(
            'AP',
            style: QvTextStyles.body.copyWith(
                color: colorScheme.onSurface, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Row 1 — health bar / class-resource block. Now CharacterVitalsRow
// (lib/widgets/qv_character_vitals_row.dart), pulled out to a shared
// widget so the Combat page's own vitals+skills card can reuse the exact
// same styling — see that file's own doc comment.

// Row 2 — one cooldown slot per equipped active skill (up to 5), real
// SkillButtonColor/cooldown data straight from PlayerCubit/TodosOverviewCubit
// — no placeholder generation. An empty loadout (nothing slotted yet) just
// renders no slots, same as a class with fewer than 5 active skills unlocked.
class _SkillCooldownRow extends StatelessWidget {
  final List<BaseActiveSkill> skills;
  final Map<String, ScheduledTimer> skillCooldowns;
  const _SkillCooldownRow(
      {required this.skills, required this.skillCooldowns});

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          'No skills equipped',
          textAlign: TextAlign.center,
          style: QvTextStyles.caption
              .copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
      );
    }
    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(skills.length, (index) {
          final skill = skills[index];
          return Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(right: index == skills.length - 1 ? 0 : 6),
              child: _SkillCooldownSlot(
                skill: skill,
                cooldownTimer: skillCooldowns[skill.id],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// QvButton's ButtonColor is the generic 9-slice button skin (also used for
// rarity/theme buttons app-wide); SkillButtonColor is the skill-specific
// icon/border pairing QvSkillButton reads. This slot renders as a plain
// QvButton (no icon), so it maps down to the nearest ButtonColor instead —
// weaponType (Warrior/Rogue's non-elemental skills) has no elemental
// equivalent here, so it falls back to silver, ButtonColor's own neutral
// tone.
ButtonColor _buttonColorForSkill(SkillButtonColor color) {
  switch (color) {
    case SkillButtonColor.weaponType:
      return ButtonColor.silver;
    case SkillButtonColor.fireRed:
      return ButtonColor.fireRed;
    case SkillButtonColor.iceBlue:
      return ButtonColor.iceBlue;
    case SkillButtonColor.arcanePurple:
      return ButtonColor.arcanePurple;
  }
}

class _SkillCooldownSlot extends StatelessWidget {
  final BaseActiveSkill skill;
  final ScheduledTimer? cooldownTimer;
  const _SkillCooldownSlot({required this.skill, this.cooldownTimer});

  @override
  Widget build(BuildContext context) {
    final timer = cooldownTimer;
    final now = DateTime.now();
    final remaining = timer != null && timer.nextTriggerAt.isAfter(now)
        ? timer.nextTriggerAt.difference(now)
        : null;
    final onCooldown = remaining != null;
    return QvButton(
      buttonColor: _buttonColorForSkill(skill.data.buttonColor),
      darkened: onCooldown,
      child: Center(
        child: onCooldown
            ? Text(
                DataFormatters.formatCountdown(remaining),
                style: QvTextStyles.itemTitle.copyWith(color: Colors.white),
              )
            : const Icon(Symbols.check, color: Colors.white, size: 20),
      ),
    );
  }
}

// Row 3 — in-combat enemy state. Real in-combat detection + enemy health;
// placeholder attack timers only (see class doc comment above). Each enemy
// gets its own inset background rather than the row sharing one big panel.
class _CombatEnemiesSection extends StatelessWidget {
  final TodosOverviewState state;
  const _CombatEnemiesSection({required this.state});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: state.isInActiveCombat
          ? IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: (List<Enemy>.from(state.activeEncounter!.enemies)
                      ..sort((a, b) => a.position.compareTo(b.position)))
                    .map((enemy) => _EnemyCombatBlock(
                          enemy: enemy,
                          enemyData: state.enemyDataFor(enemy),
                          attackTimer: state.attackTimerFor(enemy),
                        ))
                    .toList(),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                "Not in combat — you won't earn AP from battle right now.",
                textAlign: TextAlign.center,
                style: QvTextStyles.caption.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            ),
    );
  }
}

class _EnemyCombatBlock extends StatelessWidget {
  final Enemy enemy;
  final EnemyData? enemyData;
  final ScheduledTimer? attackTimer;
  const _EnemyCombatBlock(
      {required this.enemy,
      required this.enemyData,
      required this.attackTimer});

  @override
  Widget build(BuildContext context) {
    final isDead = enemy.currentHealth <= 0;
    final now = DateTime.now();
    final attackCountdown = attackTimer == null
        ? null
        : (attackTimer!.nextTriggerAt.isAfter(now)
            ? attackTimer!.nextTriggerAt.difference(now)
            : Duration.zero);

    final colorScheme = Theme.of(context).colorScheme;
    return Opacity(
      opacity: isDead ? 0.4 : 1,
      child: QvCardBorder(
        rarityBorderAssetPath:
            (enemyData?.rarity ?? Rarity.common).borderAssetPath,
        bgColor: colorScheme.surface,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
        child: SizedBox(
          width: 90,
          child: Column(
            children: [
              QvBar(
                currentValue: enemy.currentHealth,
                maxValue: enemyData?.health ?? 0,
                size: QvBarSize.mini,
                insetBackgroundType: QvInsetBackgroundType.secondary,
                height: 26,
                child: isDead
                    ? Text(
                        'X X X',
                        style: QvTextStyles.micro
                            .copyWith(color: Colors.grey[100], height: 1),
                      )
                    : const SizedBox.shrink(),
              ),
              // Expanded+Center rather than a fixed gap so the move
              // type/timer block sits centered in whatever space is left
              // below the bar once IntrinsicHeight/CrossAxisAlignment.
              // stretch (in _CombatEnemiesSection) stretches this block to
              // match its tallest sibling.
              Expanded(
                child: Center(
                  child: isDead
                      ? Text(
                          'Defeated',
                          style: QvTextStyles.itemTitle.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        )
                      : attackTimer == null || attackCountdown == null
                          ? Text(
                              '—',
                              style: QvTextStyles.itemTitle.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  attackTimer!.payload,
                                  style: QvTextStyles.micro.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  DataFormatters.formatCountdown(
                                      attackCountdown),
                                  style: QvTextStyles.itemTitle.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
