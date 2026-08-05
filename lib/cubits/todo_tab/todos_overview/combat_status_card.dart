import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_cubit.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/providers/game_data_models/enemy_data.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_bar.dart';
import 'package:questvale/widgets/qv_card_border.dart';
import 'package:questvale/widgets/qv_inset_background.dart';

// Scaffold for the character/combat status block pinned above the todo
// list. XP (level/currentExp), health/AP/mana, and in-combat enemy state
// read real data from TodosOverviewCubit. Skill cooldowns, enemy attack
// timers, and the XP bar's exp-to-next-level threshold have no real system
// behind them yet (no leveling curve exists anywhere in the codebase), so
// those are placeholder values laid out so the real systems can slot in
// later.
class CombatStatusCard extends StatefulWidget {
  const CombatStatusCard({super.key});

  @override
  State<CombatStatusCard> createState() => _CombatStatusCardState();
}

class _CombatStatusCardState extends State<CombatStatusCard> {
  static const _skillSlotCount = 5;
  static const _placeholderColorChoices = [
    ButtonColor.fireRed,
    ButtonColor.iceBlue,
    ButtonColor.arcanePurple,
  ];

  late final List<ButtonColor> _placeholderSkillColors;
  late final List<Duration> _placeholderSkillCooldowns;

  @override
  void initState() {
    super.initState();
    // Generated once per mount rather than on every build, so the row
    // doesn't reshuffle whenever an unrelated todo interaction reloads
    // TodosOverviewCubit's state.
    final random = Random();
    _placeholderSkillColors = List.generate(
      _skillSlotCount,
      (_) => _placeholderColorChoices[
          random.nextInt(_placeholderColorChoices.length)],
    );
    // Cooldowns run on an hours-scale cadence, not seconds — matches the
    // real-world-task -> AP -> combat pacing of the game. Capped at 12h,
    // seconds-granular so both the hh:mm and mm:ss display cases show up.
    _placeholderSkillCooldowns = List.generate(
      _skillSlotCount,
      (_) => Duration(seconds: random.nextInt(12 * 3600 + 1)),
    );
    // Guarantee at least one ready (no-cooldown) slot so both rectangle
    // styles are represented.
    _placeholderSkillCooldowns[random.nextInt(_skillSlotCount)] = Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodosOverviewCubit, TodosOverviewState>(
      builder: (context, state) {
        final character = state.character;
        if (character == null) return const SizedBox.shrink();
        final isExpanded = character.combatStatusCardExpanded;

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
                      _CharacterVitalsRow(character: character),
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
                              colors: _placeholderSkillColors,
                              cooldowns: _placeholderSkillCooldowns,
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
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: dividerColor)),
      ],
    );
  }
}

// Row 0 — full-width XP bar. Level and currentExp are real; the
// exp-needed-for-next-level denominator is a placeholder (level * 100)
// since no leveling/exp-curve system exists anywhere in the codebase yet.
class _ExperienceBar extends StatelessWidget {
  final Character character;
  final bool isExpanded;
  const _ExperienceBar({required this.character, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    final expForNextLevel = character.level * 100;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LVL ${character.level}',
              style: const TextStyle(
                color: EXP_COLOR,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${character.currentExp} / $expForNextLevel',
                  style: const TextStyle(
                    color: EXP_COLOR,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
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
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          Text(
            'AP',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Row 1 — health bar / mana bar, leaning toward the card's outer edges.
// Fully real: both values come straight off the loaded Character.
class _CharacterVitalsRow extends StatelessWidget {
  final Character character;
  const _CharacterVitalsRow({required this.character});

  @override
  Widget build(BuildContext context) {
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
                    '${character.currentHealth} / ${character.maxHealth}',
                    style: const TextStyle(
                      color: HEALTH_COLOR,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'HP',
                    style: const TextStyle(
                      color: HEALTH_COLOR,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              QvBar(
                currentValue: character.currentHealth,
                maxValue: character.maxHealth,
                resource: QvBarResource.health,
                size: QvBarSize.mini,
                height: 20,
                child: const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MANA',
                    style: const TextStyle(
                      color: MANA_COLOR,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${character.currentMana} / ${character.maxMana}',
                    style: const TextStyle(
                      color: MANA_COLOR,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              QvBar(
                currentValue: character.currentMana,
                maxValue: character.maxMana,
                resource: QvBarResource.mana,
                size: QvBarSize.mini,
                height: 20,
                child: const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Countdown display shared by skill cooldowns and enemy attack timers: hh:mm
// once there's at least an hour left, dropping to mm:ss once it's down to
// minutes so the last stretch reads with second-level precision.
String _formatCountdown(Duration remaining) {
  final totalSeconds = remaining.inSeconds;
  String pad(int n) => n.toString().padLeft(2, '0');
  if (totalSeconds >= Duration.secondsPerHour) {
    final hours = totalSeconds ~/ Duration.secondsPerHour;
    final minutes =
        (totalSeconds % Duration.secondsPerHour) ~/ Duration.secondsPerMinute;
    return '${pad(hours)}:${pad(minutes)}';
  }
  final minutes = totalSeconds ~/ Duration.secondsPerMinute;
  final seconds = totalSeconds % Duration.secondsPerMinute;
  return '${pad(minutes)}:${pad(seconds)}';
}

// Row 2 — 5 skill-cooldown buttons. Placeholder colors/cooldowns only; no
// live skill-cooldown tracking exists yet (see class doc comment above).
class _SkillCooldownRow extends StatelessWidget {
  final List<ButtonColor> colors;
  final List<Duration> cooldowns;
  const _SkillCooldownRow({required this.colors, required this.cooldowns});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(colors.length, (index) {
          return Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(right: index == colors.length - 1 ? 0 : 6),
              child: _SkillCooldownSlot(
                color: colors[index],
                cooldown: cooldowns[index],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SkillCooldownSlot extends StatelessWidget {
  final ButtonColor color;
  final Duration cooldown;
  const _SkillCooldownSlot({required this.color, required this.cooldown});

  @override
  Widget build(BuildContext context) {
    final onCooldown = cooldown > Duration.zero;
    return QvButton(
      buttonColor: color,
      darkened: onCooldown,
      child: Center(
        child: onCooldown
            ? Text(
                _formatCountdown(cooldown),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
                        ))
                    .toList(),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                "Not in combat — you won't earn AP from battle right now.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ),
    );
  }
}

// Placeholder for the enemy's next-move type — no such system exists yet
// (see class doc comment above); this stands in for whatever real enum
// eventually classifies an enemy move as attack/buff/debuff/etc.
enum _EnemyMoveType {
  attack,
  buff,
  debuff;

  String get label {
    switch (this) {
      case _EnemyMoveType.attack:
        return 'Attack';
      case _EnemyMoveType.buff:
        return 'Buff';
      case _EnemyMoveType.debuff:
        return 'Debuff';
    }
  }
}

class _EnemyCombatBlock extends StatelessWidget {
  final Enemy enemy;
  final EnemyData? enemyData;
  const _EnemyCombatBlock({required this.enemy, required this.enemyData});

  @override
  Widget build(BuildContext context) {
    final isDead = enemy.currentHealth <= 0;
    // Stable per-enemy placeholders (seeded off the enemy id, salted
    // differently per field so they don't move in lockstep) so neither
    // jumps around on every reload — no live attack-timer or move-type
    // system exists yet. Attacks land on an hours-scale cadence, not
    // seconds.
    final placeholderAttackTime =
        Duration(seconds: Random(enemy.id.hashCode).nextInt(24 * 3600) + 1);
    final placeholderMoveType = _EnemyMoveType.values[
        Random(enemy.id.hashCode + 1).nextInt(_EnemyMoveType.values.length)];

    final colorScheme = Theme.of(context).colorScheme;
    return Opacity(
      opacity: isDead ? 0.4 : 1,
      child: QvCardBorder(
        rarity: enemyData?.rarity ?? Rarity.common,
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
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[100],
                          height: 1,
                        ),
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
                      ? const Text(
                          'Defeated',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              placeholderMoveType.label,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _formatCountdown(placeholderAttackTime),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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
