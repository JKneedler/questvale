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

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: QvButton(
            buttonColor: ButtonColor.surfaceContainer,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ExperienceBar(character: character),
                const SizedBox(height: 6),
                _CharacterVitalsRow(character: character),
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
  const _ExperienceBar({required this.character});

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
              'Lvl ${character.level}',
              style: const TextStyle(
                color: EXP_COLOR,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              '${character.currentExp} / $expForNextLevel',
              style: const TextStyle(
                color: EXP_COLOR,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
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

// Row 1 — health bar / AP block / mana bar. Fully real: all three values
// come straight off the loaded Character.
class _CharacterVitalsRow extends StatelessWidget {
  final Character character;
  const _CharacterVitalsRow({required this.character});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${character.currentHealth} / ${character.maxHealth}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: HEALTH_COLOR,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: QvButton(
            buttonColor: ButtonColor.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${character.actionPoints}',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                Text(
                  'AP',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${character.currentMana} / ${character.maxMana}',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  color: MANA_COLOR,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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

// Mirrors QvCardBorder's rarity-mini look (same border asset) but, like
// _PrimaryBorderCard above, uses Container/DecorationImage instead of
// QvCardBorder's Stack+FractionallySizedBox so it sizes safely off its
// child's intrinsic content in this unbounded-height list context.
class _RarityMiniBorder extends StatelessWidget {
  final Rarity rarity;
  final Widget child;
  const _RarityMiniBorder({required this.rarity, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: STANDARD_BORDER_MIN_SIZE.width,
        minHeight: STANDARD_BORDER_MIN_SIZE.height,
      ),
      child: Stack(
        children: [
          // Inset from the border art's own bounds — same fix as
          // _PrimaryBorderCard — so the flat fill doesn't show through the
          // border's rounded corners.
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: ColoredBox(color: colorScheme.surface),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(rarity.borderAssetPath),
                centerSlice: STANDARD_BORDER_SLICE,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.none,
              ),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _EnemyCombatBlock extends StatelessWidget {
  final Enemy enemy;
  final EnemyData? enemyData;
  const _EnemyCombatBlock({required this.enemy, required this.enemyData});

  @override
  Widget build(BuildContext context) {
    final isDead = enemy.currentHealth <= 0;
    // Stable per-enemy placeholder (seeded off the enemy id) so it doesn't
    // jump around on every reload — no live attack-timer system exists yet.
    // Attacks land on an hours-scale cadence, not seconds.
    final placeholderAttackTime =
        Duration(seconds: Random(enemy.id.hashCode).nextInt(24 * 3600) + 1);

    return Opacity(
      opacity: isDead ? 0.4 : 1,
      child: _RarityMiniBorder(
        rarity: enemyData?.rarity ?? Rarity.common,
        child: SizedBox(
          width: 90,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QvBar(
                currentValue: enemy.currentHealth,
                maxValue: enemyData?.health ?? 0,
                size: QvBarSize.mini,
                insetBackgroundType: QvInsetBackgroundType.secondary,
                height: 26,
                child: Text(
                  isDead
                      ? 'X X X'
                      : '${enemy.currentHealth} / ${enemyData?.health ?? 0}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[100],
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isDead ? 'Defeated' : _formatCountdown(placeholderAttackTime),
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
    );
  }
}
