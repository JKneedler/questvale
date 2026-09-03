import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/nav_cubit.dart';
import 'package:questvale/cubits/home/nav_state.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/world_tab/questing/combat/combat_cubit.dart';
import 'package:questvale/cubits/world_tab/questing/combat/combat_state.dart';
import 'package:questvale/cubits/world_tab/questing/quest_encounter/quest_encounter_cubit.dart';
import 'package:questvale/cubits/world_tab/questing/quest_encounter/quest_flee_confirmation_modal.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/models/scheduled_timer.dart';
import 'package:questvale/data/providers/game_data_models/enemy_attack_data.dart';
import 'package:questvale/data/providers/game_data_models/enemy_data.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/helpers/data_formatters.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/widgets/qv_damage_toast.dart';
import 'package:jk_pixel_ui/jk_pixel_ui.dart';

// Shared with TargetEnemySkillBox's effect-line list below — same
// formatting convention as skills_gear_up_page.dart's identically-named
// top-level helpers (SkillEffectComponent.baseValue is stored as a
// fraction, e.g. 0.2 == 20%).
String _percentText(double value) => '${(value * 100).round()}%';

String _capitalize(String value) =>
    value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

// SkillData.cooldown is in fractional hours (e.g. 0.5 for Firebolt) — see
// its own doc comment. 0/null both mean "no cooldown" (Arcane Bolt).
String _cooldownText(double? cooldownHours) {
  final hours = cooldownHours ?? 0;
  if (hours <= 0) return 'None';
  final wholeHours = hours.floor();
  final minutes = ((hours % 1) * 60).round();
  if (wholeHours == 0) return '${minutes}m';
  if (minutes == 0) return '${wholeHours}h';
  return '${wholeHours}h ${minutes}m';
}

// CombatCubit is now provided by QuestEncounterView, not created here — see
// its own doc comment. Live combat's own step in the quest flow no longer
// needs a StatefulWidget of its own for this: NavCubit's
// setShowCombatNavBackground toggle (formerly hooked to this page's own
// initState/dispose) now spans the whole quest-encounter flow instead, and
// belongs to QuestEncounterView for the same reason.
class CombatView extends StatelessWidget {
  const CombatView({super.key});

  Alignment getAlignment(int index, int totalEnemies) {
    if (totalEnemies == 3) {
      return index == 1 ? Alignment.center : Alignment.centerRight;
    }
    return Alignment.center;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CombatCubit, CombatState>(
        builder: (context, combatState) {
      return MultiBlocListener(
        listeners: [
          BlocListener<CombatCubit, CombatState>(
            listenWhen: (prev, next) =>
                prev.status != CombatStatus.complete &&
                next.status == CombatStatus.complete,
            listener: (context, combatState) async {
              if (combatState.status == CombatStatus.complete) {
                await context.read<QuestEncounterCubit>().completeEncounter();
              }
            },
          ),
          BlocListener<CombatCubit, CombatState>(
            listenWhen: (prev, next) =>
                next.lastEnemyDamageTaken != null &&
                next.lastEnemyDamageTaken != prev.lastEnemyDamageTaken,
            listener: (context, combatState) =>
                showDamageToast(context, combatState.lastEnemyDamageTaken!),
          ),
          // See NavState.combatRefreshRequestId's doc comment — an admin
          // action elsewhere (Settings' Reset all skill cooldowns) can
          // change DB state this page's own CombatCubit has no other way
          // to learn about while it sits mounted-but-backgrounded under
          // HomeView's IndexedStack.
          BlocListener<NavCubit, NavState>(
            listenWhen: (prev, next) =>
                next.combatRefreshRequestId != prev.combatRefreshRequestId,
            listener: (context, navState) =>
                context.read<CombatCubit>().reload(),
          ),
        ],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _CombatActionBar(combatState: combatState),
            BattleFieldDisplay(),
          ],
        ),
      );
    });
  }
}

// Flee/Potions/Bag, in one row — sits directly below QvQuestEncounterHeader
// with no gap, on the same surfaceNoTop texture (flat top, since the
// header's own filler bar above already continues into it; capped bottom,
// closing off the region). Per feedback: previously two floating,
// unstyled columns (Flee+Potions stacked on the left, Bag alone on the
// right) with the header's own cap ending right below "Encounter X / Y" —
// QvQuestEncounterHeader.capBottom is false specifically during live
// combat so that cap moves down to end here instead, making the header
// text and this button row read as one continuous background instead of
// two separately-capped pieces with a seam between them.
//
// Buttons are Expanded (no explicit width) rather than fixed 64x64
// squares, so they stretch to fill the row's full width evenly instead of
// clustering with dead space between them — combined with a shorter fixed
// height, this whole bar is noticeably more compact vertically than the
// original two-column layout, leaving more room for BattleFieldDisplay
// below it.
//
// All three buttons share ButtonColor.surfaceContainer — previously each
// had its own color (silver, rare, surface), unrelated to any other list
// item's own styling. Per feedback, now matches the color the Todo tab's
// own list items use (see todos_overview_item.dart), and CombatStatusCard's
// outer shell there too.
class _CombatActionBar extends StatelessWidget {
  const _CombatActionBar({required this.combatState});

  final CombatState combatState;

  static const double _buttonHeight = 48;
  static const double _iconSize = 32;

  @override
  Widget build(BuildContext context) {
    return QvBackground(
      type: QvBackgroundType.surfaceNoTop,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        spacing: 10,
        children: [
          Expanded(
            child: QvButton(
              height: _buttonHeight,
              buttonColor: ButtonColor.surfaceContainer,
              onTap: () {
                if (combatState.status == CombatStatus.idle) {
                  QuestFleeConfirmationModal.showModal(context,
                      () => context.read<QuestEncounterCubit>().fleeQuest());
                }
              },
              child: Center(
                child: Image.asset(
                  'images/pixel-icons/running-man.png',
                  filterQuality: FilterQuality.none,
                  width: _iconSize,
                  height: _iconSize,
                  scale: .08,
                ),
              ),
            ),
          ),
          Expanded(
            child: QvButton(
              height: _buttonHeight,
              buttonColor: ButtonColor.surfaceContainer,
              child: Center(
                child: Image.asset(
                  'images/pixel-icons/potion-star.png',
                  filterQuality: FilterQuality.none,
                  width: _iconSize,
                  height: _iconSize,
                  scale: .08,
                ),
              ),
            ),
          ),
          Expanded(
            child: QvButton(
              height: _buttonHeight,
              buttonColor: ButtonColor.surfaceContainer,
              child: Center(
                child: Image.asset(
                  'images/pixel-icons/bag.png',
                  filterQuality: FilterQuality.none,
                  width: _iconSize,
                  height: _iconSize,
                  scale: .08,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BattleFieldDisplay extends StatelessWidget {
  const BattleFieldDisplay({super.key});

  MainAxisAlignment getAlignment(int index, int totalEnemies) {
    if (totalEnemies == 3) {
      return index == 1 ? MainAxisAlignment.center : MainAxisAlignment.end;
    }
    return MainAxisAlignment.center;
  }

  QvAnimatedTransitionType getEnemyInfoBoxTransitionType(
      CombatState combatState) {
    if (combatState.status == CombatStatus.inspectingEnemy &&
        combatState.inspectingEnemyIndex != -1) {
      return QvAnimatedTransitionType.slideLeft;
    }
    return QvAnimatedTransitionType.slideRight;
  }

  QvAnimatedTransitionType getPlayerInfoBoxTransitionType(
      CombatState combatState) {
    if (combatState.status == CombatStatus.inspectingPlayer) {
      return QvAnimatedTransitionType.slideRight;
    }
    return QvAnimatedTransitionType.slideLeft;
  }

  QvAnimatedTransitionType getSkillAnimationTransitionType(
      CombatState combatState) {
    if (combatState.status == CombatStatus.targetingSkill) {
      return QvAnimatedTransitionType.slideRight;
    }
    return QvAnimatedTransitionType.slideLeft;
  }

  @override
  Widget build(BuildContext context) {
    final combatState = context.read<CombatCubit>().state;

    return Expanded(
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () =>
                            context.read<CombatCubit>().onPlayerTap(context),
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: Image.asset(
                            'images/characters/mage.png',
                            filterQuality: FilterQuality.none,
                            width: 100,
                            height: 100,
                            scale: .1,
                          ),
                        ),
                      ),
                    ),
                    QvAnimatedTransition(
                      duration: Duration(milliseconds: 200),
                      type: getSkillAnimationTransitionType(combatState),
                      child: (combatState.status == CombatStatus.targetingSkill)
                          ? TargetEnemySkillBox(
                              skill: combatState.targetingSkill!)
                          : SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  // top/bottom trimmed from 40 to 24 — the new AP badge row
                  // in CombatVitalsAndSkillsCard added ~32px below, shrinking
                  // this Expanded area enough to overflow the enemy column
                  // by a few px; this reclaims that headroom at the source
                  // rather than shrinking the badge to compensate.
                  padding: const EdgeInsets.only(
                      left: 30, right: 30, top: 24, bottom: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int i = 0; i < combatState.enemies.length; i++)
                        EnemyDisplay(
                          enemy: combatState.enemies[i],
                          onTap: () => context
                              .read<CombatCubit>()
                              .onEnemyTap(context, i),
                          alignment:
                              getAlignment(i, combatState.enemies.length),
                          isTargeted: combatState.status ==
                                  CombatStatus.targetingSkill &&
                              (combatState.target.getEnemyIndex() == i ||
                                  (combatState.target == SkillTarget.all &&
                                      combatState.enemies[i].currentHealth >
                                          0)),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          QvAnimatedTransition(
            duration: Duration(milliseconds: 200),
            type: getEnemyInfoBoxTransitionType(combatState),
            child: (combatState.status == CombatStatus.inspectingEnemy &&
                    combatState.inspectingEnemyIndex != -1)
                ? EnemyInfoBox(
                    enemy:
                        combatState.enemies[combatState.inspectingEnemyIndex])
                : SizedBox.shrink(),
          ),
          QvAnimatedTransition(
            duration: Duration(milliseconds: 200),
            type: getPlayerInfoBoxTransitionType(combatState),
            child: (combatState.status == CombatStatus.inspectingPlayer)
                ? PlayerInfoBox()
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class EnemyDisplay extends StatelessWidget {
  final Enemy enemy;
  final MainAxisAlignment alignment;
  final VoidCallback onTap;
  final bool isTargeted;

  const EnemyDisplay(
      {super.key,
      required this.enemy,
      required this.alignment,
      required this.onTap,
      required this.isTargeted});

  @override
  Widget build(BuildContext context) {
    final questZones = context.read<QuestEncounterCubit>().questZone;
    final enemyData = questZones.enemies
        .firstWhere((enemyData) => enemyData.id == enemy.enemyDataId);
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: alignment,
        children: [
          isTargeted
              ? QvBlinking(
                  duration: Duration(milliseconds: 500),
                  minOpacity: 0.2,
                  curve: Curves.bounceInOut,
                  isBlinking: true,
                  child: Image.asset(
                    'images/ui/icons/small-side-arrow.png',
                    filterQuality: FilterQuality.none,
                    width: 20,
                    height: 20,
                    scale: .1,
                  ),
                )
              : SizedBox(width: 20),
          SizedBox(width: 10),
          Column(
            children: [
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(3.1415926535),
                child: Image.asset(
                  'images/enemies/${enemyData.id.toLowerCase()}.png',
                  filterQuality: FilterQuality.none,
                  width: 80,
                  height: 80,
                  scale: .1,
                ),
              ),
              Container(
                height: 6,
                width: 70,
                color: Colors.white.withValues(alpha: 0.4),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: enemy.currentHealth / enemyData.health,
                  child: Container(height: 6, color: HEALTH_COLOR),
                ),
              ),
              // Text(
              //   '${enemy.currentHealth} / ${enemyData.health}',
              //   style: TextStyle(
              //     fontSize: 18,
              //     color: Colors.grey[100],
              //     height: 1,
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

class EnemyInfoBox extends StatelessWidget {
  final Enemy enemy;

  const EnemyInfoBox({super.key, required this.enemy});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final enemyData = context
        .read<QuestEncounterCubit>()
        .questZone
        .enemies
        .firstWhere((enemyData) => enemyData.id == enemy.enemyDataId);
    return Padding(
      padding: EdgeInsets.all(6),
      child: QvButton(
        buttonColor: ButtonColor.surfaceContainer,
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  QvCardBorder(
                    width: 80,
                    height: 80,
                    rarityBorderAssetPath: enemyData.rarity.borderAssetPath,
                    child: Image.asset(
                      'images/enemies/${enemyData.id.toLowerCase()}.png',
                      filterQuality: FilterQuality.none,
                      width: 80,
                      height: 80,
                      scale: .1,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        QvButton(
                          height: 36,
                          buttonColor: rarityButtonColor(enemyData.rarity),
                          child: Center(
                              child: Text(
                            enemyData.name,
                            style: QvTextStyles.title
                                .copyWith(color: colorScheme.secondary),
                          )),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: QvBar(
                            currentValue: enemy.currentHealth,
                            maxValue: enemyData.health,
                            insetBackgroundType:
                                QvInsetBackgroundType.secondary,
                            child: Text(
                              '${enemy.currentHealth} / ${enemyData.health}',
                              style: QvTextStyles.detail
                                  .copyWith(color: Colors.grey[100], height: 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: QvFadingScrollable(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      EnemyNextAttackSlice(
                        attackTimer: context
                            .read<CombatCubit>()
                            .state
                            .attackTimerFor(enemy),
                        enemyData: enemyData,
                      ),
                      EnemyStatusEffectsSlice(),
                      Text(enemyData.rarity.name.toUpperCase()),
                      Text(enemyData.enemyType.name.toUpperCase()),
                      Text(enemyData.immunities
                          .map((immunity) => immunity.name.toUpperCase())
                          .join(', ')),
                      Text(enemyData.resistances
                          .map((resistance) => resistance.name.toUpperCase())
                          .join(', ')),
                      Text(enemyData.weaknesses
                          .map((weakness) => weakness.name.toUpperCase())
                          .join(', ')),
                      Text(enemyData.attacks
                          .map((attack) => attack.name.toUpperCase())
                          .join(', ')),
                      Text(enemyData.drops
                          .map((drop) => drop.itemName.toUpperCase())
                          .join(', ')),
                    ],
                  ),
                ),
              ),
            ),
            QvButton(
              width: double.infinity,
              height: 36,
              buttonColor: ButtonColor.primary,
              onTap: () => context.read<CombatCubit>().setIdle(),
              child: Center(
                  child: Text(
                'Close',
                style:
                    QvTextStyles.title.copyWith(color: colorScheme.secondary),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class EnemyNextAttackSlice extends StatefulWidget {
  final ScheduledTimer? attackTimer;
  final EnemyData enemyData;

  const EnemyNextAttackSlice(
      {super.key, required this.attackTimer, required this.enemyData});

  @override
  State<EnemyNextAttackSlice> createState() => _EnemyNextAttackSliceState();
}

class _EnemyNextAttackSliceState extends State<EnemyNextAttackSlice> {
  Timer? _countdownRefreshTimer;

  @override
  void initState() {
    super.initState();
    // Recomputes nextTriggerAt - now() every second, so the countdown
    // visibly ticks down rather than jumping in chunks — purely
    // presentational when nothing has expired yet. But once the timer has
    // actually reached zero, ticking the display alone would freeze it at
    // 00:00 forever: nothing else re-triggers reconciliation while this
    // box is open. Route through CombatCubit.reload() (which reconciles)
    // instead.
    _countdownRefreshTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;
        final timer = widget.attackTimer;
        if (timer != null && !timer.nextTriggerAt.isAfter(DateTime.now())) {
          context.read<CombatCubit>().reload();
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
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final themeId = context.watch<ThemeCubit>().state.theme.id;

    final timer = widget.attackTimer;
    EnemyAttackData? attack;
    String countdownLabel = '—';
    if (timer != null) {
      final now = DateTime.now();
      final remaining = timer.nextTriggerAt.isAfter(now)
          ? timer.nextTriggerAt.difference(now)
          : Duration.zero;
      countdownLabel = DataFormatters.formatCountdown(remaining);
      attack = widget.enemyData.attacks
          .firstWhereOrNull((a) => a.name == timer.payload);
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              'Next Attack',
              style: QvTextStyles.note
                  .copyWith(color: colorScheme.primary, height: 1),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: jkAsset(
                  'images/ui/backgrounds/$themeId/background-secondary.png'),
              centerSlice: STANDARD_BORDER_SLICE,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            ),
          ),
          child: Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(
                  child: Text(countdownLabel,
                      style: QvTextStyles.label
                          .copyWith(color: Colors.grey[100], height: 1),
                      textAlign: TextAlign.center)),
              Container(width: 2, height: 20, color: colorScheme.primary),
              SizedBox(width: 20),
              Expanded(
                  flex: 3,
                  child: Text(
                    attack?.name ?? '—',
                    style: QvTextStyles.label
                        .copyWith(color: colorScheme.primary, height: 1),
                  )),
              Expanded(
                  child: Text(attack == null ? '—' : '${attack.damage}',
                      style: QvTextStyles.label
                          .copyWith(color: colorScheme.primary, height: 1),
                      textAlign: TextAlign.center)),
            ],
          ),
        ),
      ],
    );
  }
}

class EnemyStatusEffectsSlice extends StatelessWidget {
  const EnemyStatusEffectsSlice({super.key});

  @override
  Widget build(BuildContext context) {
    final themeId = context.watch<ThemeCubit>().state.theme.id;
    return Column(
      children: [
        Text('Status Effects'),
        Container(
          height: 40,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: jkAsset(
                  'images/ui/backgrounds/$themeId/background-secondary.png'),
              centerSlice: STANDARD_BORDER_SLICE,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            ),
          ),
        ),
      ],
    );
  }
}

class PlayerInfoBox extends StatelessWidget {
  const PlayerInfoBox({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.all(20),
      child: QvButton(
        buttonColor: ButtonColor.surfaceContainer,
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Text('Player'),
            Expanded(child: Container()),
            QvButton(
              width: double.infinity,
              height: 36,
              buttonColor: ButtonColor.primary,
              onTap: () => context.read<CombatCubit>().setIdle(),
              child: Center(
                  child: Text(
                'Close',
                style:
                    QvTextStyles.title.copyWith(color: colorScheme.secondary),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class TargetEnemySkillBox extends StatelessWidget {
  final BaseActiveSkill skill;
  const TargetEnemySkillBox({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final playerCombatStats =
        context.read<PlayerCubit>().state.playerCombatStats;
    if (playerCombatStats == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.all(6),
      child: QvButton(
        buttonColor: ButtonColor.surfaceContainer,
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Text(skill.data.name),
            Text('Lv ${skill.level}',
                style:
                    QvTextStyles.micro.copyWith(color: colorScheme.onSurface)),
            Text(skill.description),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                  'AP Cost: ${skill.data.apCost ?? 0} • Cooldown: ${_cooldownText(skill.data.cooldown)}',
                  style: QvTextStyles.caption.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.75))),
            ),
            ..._effectLines(playerCombatStats).map((line) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(line,
                      style: QvTextStyles.caption
                          .copyWith(color: colorScheme.onSurface)),
                )),
            Expanded(child: Container()),
            QvButton(
              width: double.infinity,
              height: 36,
              buttonColor: ButtonColor.primary,
              onTap: () =>
                  context.read<CombatCubit>().onAttackButtonTap(context),
              child: Center(
                  child: Text(
                'Attack',
                style:
                    QvTextStyles.title.copyWith(color: colorScheme.secondary),
              )),
            ),
          ],
        ),
      ),
    );
  }

  // One line per real effect component this skill actually declares —
  // damage, shield, status-effect proc chance — rather than the old fixed
  // Damage/Damage Type pair, which showed a misleading blank/zero damage
  // line for a skill with no damage component at all (e.g. Frost Armor).
  // Values are computed the same way each skill's own execute() computes
  // them (attackPowerFor for damage, maxHealth-scaled for shield) so what
  // this panel shows matches what actually lands when Attack is tapped.
  List<String> _effectLines(PlayerCombatStats playerCombatStats) {
    final lines = <String>[];

    final damage = skill.data.damageEffect;
    if (damage != null) {
      final amount = (damage.valueAtLevel(skill.level) *
              playerCombatStats.attackPowerFor(
                  damage.damageType ?? SkillDamageType.physical))
          .round();
      lines.add('${damage.damageType?.name ?? 'Weapon Type'} Damage: $amount');
    }

    final shield = skill.data.shieldEffect;
    if (shield != null) {
      final amount =
          (shield.valueAtLevel(skill.level) * playerCombatStats.maxHealth)
              .round();
      lines.add('Shield: $amount HP');
    }

    for (final chance in skill.data.statusEffectChances) {
      final label = _capitalize(chance.statusEffectType?.name ?? 'Status');
      lines.add(
          '$label Chance: ${_percentText(chance.valueAtLevel(skill.level))}');
    }

    return lines;
  }
}
