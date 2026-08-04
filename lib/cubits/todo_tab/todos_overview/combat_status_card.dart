import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/theme/theme_cubit.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_cubit.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/providers/game_data_models/enemy_data.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/widgets/qv_inset_background.dart';
import 'package:questvale/widgets/qv_resource_bar.dart';

// Scaffold for the character/combat status block pinned above the todo
// list. Health/AP/mana (row 1) and in-combat enemy state (row 3) read real
// data from TodosOverviewCubit. Skill cooldowns (row 2) and enemy attack
// timers (row 3) have no live tracking system yet, so those are placeholder
// values laid out so the real systems can slot in later.
class CombatStatusCard extends StatefulWidget {
  const CombatStatusCard({super.key});

  @override
  State<CombatStatusCard> createState() => _CombatStatusCardState();
}

class _CombatStatusCardState extends State<CombatStatusCard> {
  static const _skillSlotCount = 5;

  late final List<SkillButtonColor> _placeholderSkillColors;
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
      (_) => SkillButtonColor
          .values[random.nextInt(SkillButtonColor.values.length)],
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
          child: _PrimaryBorderCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CharacterVitalsRow(character: character),
                const SizedBox(height: 10),
                _SkillCooldownRow(
                  colors: _placeholderSkillColors,
                  cooldowns: _placeholderSkillCooldowns,
                ),
                const SizedBox(height: 14),
                const _HorizontalDivider(),
                const SizedBox(height: 14),
                _CombatEnemiesSection(state: state),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Separates the player's own stats/skills from the current-combat enemy
// state below it.
class _HorizontalDivider extends StatelessWidget {
  const _HorizontalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
    );
  }
}

// Mirrors QvPrimaryBorder's look (same border asset) but sizes itself off
// its child's intrinsic content instead of a FractionallySizedBox, which
// would throw when placed at the top of a ListView.builder item — list
// items get unbounded height, and QvPrimaryBorder/QvCardBorder need a
// bounded parent size to resolve their height factor.
class _PrimaryBorderCard extends StatelessWidget {
  final Widget child;
  const _PrimaryBorderCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final themeId = context.watch<ThemeCubit>().state.theme.id;
    final colorScheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: STANDARD_BORDER_MIN_SIZE.width,
        minHeight: STANDARD_BORDER_MIN_SIZE.height,
      ),
      child: Stack(
        children: [
          // Inset from the border art's own bounds so the flat fill doesn't
          // show through the border's rounded corners or get undercut by
          // the drop-shadow baked into the bottom edge of the asset.
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ColoredBox(color: colorScheme.surfaceContainer),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage('images/ui/borders/$themeId/border-primary.png'),
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
          child: QvResourceBar(
            color: HEALTH_COLOR,
            maxValue: character.maxHealth,
            currentValue: character.currentHealth,
            alignment: Alignment.centerLeft,
            height: 22,
            fontSize: 13,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: QvInsetBackground(
            type: QvInsetBackgroundType.secondary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AP',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${character.actionPoints}',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: QvResourceBar(
            color: MANA_COLOR,
            maxValue: character.maxMana,
            currentValue: character.currentMana,
            alignment: Alignment.centerRight,
            height: 22,
            fontSize: 13,
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

// Row 2 — 5 skill-cooldown rectangles. Placeholder colors/cooldowns only;
// no live skill-cooldown tracking exists yet (see class doc comment above).
class _SkillCooldownRow extends StatelessWidget {
  final List<SkillButtonColor> colors;
  final List<Duration> cooldowns;
  const _SkillCooldownRow({required this.colors, required this.cooldowns});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        // Row's default crossAxisAlignment (center) lets each slot's
        // Container shrink-wrap to whatever it contains — an empty
        // (ready) slot has no non-positioned child to size against and
        // collapses toward zero height. Stretch forces every slot to
        // fill the full 40px regardless of content.
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
  final SkillButtonColor color;
  final Duration cooldown;
  const _SkillCooldownSlot({required this.color, required this.cooldown});

  @override
  Widget build(BuildContext context) {
    final onCooldown = cooldown > Duration.zero;
    // Same Stack shape whether on cooldown or not (just an invisible overlay
    // + no text when ready) so every slot resolves to an identical size.
    return Container(
      decoration: BoxDecoration(
        color: color.backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: onCooldown ? 0.5 : 0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          if (onCooldown)
            Text(
              _formatCountdown(cooldown),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
    final healthFraction = (enemyData != null && enemyData!.health > 0)
        ? (enemy.currentHealth / enemyData!.health).clamp(0.0, 1.0)
        : 0.0;
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
              Container(
                height: 16,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isDead
                    ? const Text(
                        'X X X',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: healthFraction,
                        child: Container(
                          decoration: BoxDecoration(
                            color: HEALTH_COLOR,
                            borderRadius: BorderRadius.circular(4),
                          ),
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
