import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/nav_cubit.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/home/player_state.dart';
import 'package:questvale/cubits/world_tab/questing/combat/combat_cubit.dart';
import 'package:questvale/cubits/world_tab/questing/combat/combat_state.dart';
import 'package:questvale/cubits/world_tab/questing/quest_encounter/quest_encounter_cubit.dart';
import 'package:questvale/cubits/world_tab/questing/quest_encounter/quest_flee_confirmation_modal.dart';
import 'package:questvale/cubits/theme/theme_cubit.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/mage_motes.dart';
import 'package:questvale/data/models/player_combat_stats.dart';
import 'package:questvale/data/models/scheduled_timer.dart';
import 'package:questvale/data/providers/game_data_models/enemy_attack_data.dart';
import 'package:questvale/data/providers/game_data_models/enemy_data.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/helpers/data_formatters.dart';
import 'package:questvale/widgets/qv_animated_transition.dart';
import 'package:questvale/widgets/qv_background.dart';
import 'package:questvale/widgets/qv_blinking.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_card_border.dart';
import 'package:questvale/widgets/qv_character_vitals_row.dart';
import 'package:questvale/widgets/qv_damage_toast.dart';
import 'package:questvale/widgets/qv_fading_scrollable.dart';
import 'package:questvale/widgets/qv_inset_background.dart';
import 'package:questvale/widgets/qv_bar.dart';
import 'package:questvale/widgets/qv_skill_button.dart';
import 'package:questvale/widgets/qv_text_styles.dart';
import 'package:sqflite/sqflite.dart';

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

class CombatPage extends StatefulWidget {
  const CombatPage({super.key, required this.encounterId});
  final String encounterId;

  @override
  State<CombatPage> createState() => _CombatPageState();
}

// StatefulWidget (rather than the StatelessWidget this used to be) purely
// to hook NavBar's own useCombatBackground over its mounted lifetime — see
// NavState.showCombatNavBackground's doc comment. NavCubit is captured
// once in initState rather than re-read via context in dispose, since
// reading InheritedWidgets from a State that's already mid-teardown is
// fragile; a plain captured reference isn't. The toggle-on call is
// deferred a frame (addPostFrameCallback) because emitting into NavCubit
// synchronously from initState — while this exact frame's build is still
// in progress — risks flutter_bloc's BlocBuilder above (HomeView's own)
// calling setState mid-build; the mounted check guards the rare case
// where this page unmounts again before that deferred callback fires.
class _CombatPageState extends State<CombatPage> {
  late final NavCubit _navCubit;

  @override
  void initState() {
    super.initState();
    _navCubit = context.read<NavCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _navCubit.setShowCombatNavBackground(true);
    });
  }

  @override
  void dispose() {
    _navCubit.setShowCombatNavBackground(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CombatCubit>(
        create: (context) => CombatCubit(
              encounterId: widget.encounterId,
              questZone: context.read<QuestEncounterCubit>().questZone,
              playerCubit: context.read<PlayerCubit>(),
              db: context.read<Database>(),
            ),
        child: const CombatView());
  }
}

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
        ],
        child: BlocBuilder<PlayerCubit, PlayerState>(
            builder: (context, playerState) {
          final character = playerState.character;
          final playerSkills = playerState.playerSkills;
          final playerCombatStats = playerState.playerCombatStats;
          if (character == null ||
              playerSkills == null ||
              playerCombatStats == null) {
            return const SizedBox.shrink();
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CombatActionBar(combatState: combatState),
              BattleFieldDisplay(),
              const SizedBox(height: 10),
              CombatVitalsAndSkillsCard(
                character: character,
                mageMotes: playerState.mageMotes,
                playerSkills: playerSkills,
                combatState: combatState,
              ),
            ],
          );
        }),
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

// Skill buttons + health/motes, as one list-item area — no gap below it
// down to the nav bar (see CombatView.build, which used to add a trailing
// spacer here), and a QvBackground(surfaceNoBottom) shell instead of a
// bordered QvButton card: that texture's flat, cap-free bottom edge is
// what actually sells "extension of the nav bar" — a bordered button shape
// would still read as a floating card even with the gap removed. Colored
// off colorScheme.surface specifically (a new button-surface-no-bottom.png
// per theme, not the surfaceContainer default QvBackground normally uses)
// because that's the exact color NavBar itself paints its own Material
// with (see nav_bar.dart) — matching it, not just approximating it, is
// what makes the seam disappear.
//
// Health/motes still reuses CombatStatusCard's exact CharacterVitalsRow
// (todos_overview/combat_status_card.dart) so the two read as the same
// vitals language despite the different shell. Skill buttons stay the
// real CombatSkillButton (skill icon + level badge, live targeting/
// darkened state) rather than CombatStatusCard's placeholder cooldown
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
class CombatVitalsAndSkillsCard extends StatelessWidget {
  const CombatVitalsAndSkillsCard({
    super.key,
    required this.character,
    required this.mageMotes,
    required this.playerSkills,
    required this.combatState,
  });

  final Character character;
  final MageMotes? mageMotes;
  final PlayerSkills playerSkills;
  final CombatState combatState;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return QvBackground(
      width: double.infinity,
      type: QvBackgroundType.surfaceNoBottom,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Matches every other Town Square list-item card's own
              // leading sectionHeader label (Equipment, Weapon &
              // Artifact, Potions) — this card didn't have one yet, and
              // it fills what was otherwise a big blank stretch to the
              // AP badge's left.
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
                    onTap: () => context.read<CombatCubit>().onSkillButtonTap(
                        context, playerSkills.activeSkillSlot1!),
                    skill: playerSkills.activeSkillSlot1!,
                    darkened:
                        combatState.status == CombatStatus.targetingSkill &&
                            combatState.targetingSkill?.id !=
                                playerSkills.activeSkillSlot1!.id,
                  ),
                if (playerSkills.activeSkillSlot2 != null)
                  CombatSkillButton(
                    onTap: () => context.read<CombatCubit>().onSkillButtonTap(
                        context, playerSkills.activeSkillSlot2!),
                    skill: playerSkills.activeSkillSlot2!,
                    darkened:
                        combatState.status == CombatStatus.targetingSkill &&
                            combatState.targetingSkill?.id !=
                                playerSkills.activeSkillSlot2!.id,
                  ),
                if (playerSkills.activeSkillSlot3 != null)
                  CombatSkillButton(
                    onTap: () => context.read<CombatCubit>().onSkillButtonTap(
                        context, playerSkills.activeSkillSlot3!),
                    skill: playerSkills.activeSkillSlot3!,
                    darkened:
                        combatState.status == CombatStatus.targetingSkill &&
                            combatState.targetingSkill?.id !=
                                playerSkills.activeSkillSlot3!.id,
                  ),
                if (playerSkills.activeSkillSlot4 != null)
                  CombatSkillButton(
                    onTap: () => context.read<CombatCubit>().onSkillButtonTap(
                        context, playerSkills.activeSkillSlot4!),
                    skill: playerSkills.activeSkillSlot4!,
                    darkened:
                        combatState.status == CombatStatus.targetingSkill &&
                            combatState.targetingSkill?.id !=
                                playerSkills.activeSkillSlot4!.id,
                  ),
                if (playerSkills.activeSkillSlot5 != null)
                  CombatSkillButton(
                    onTap: () => context.read<CombatCubit>().onSkillButtonTap(
                        context, playerSkills.activeSkillSlot5!),
                    skill: playerSkills.activeSkillSlot5!,
                    darkened:
                        combatState.status == CombatStatus.targetingSkill &&
                            combatState.targetingSkill?.id !=
                                playerSkills.activeSkillSlot5!.id,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          CharacterVitalsRow(character: character, mageMotes: mageMotes),
        ],
      ),
    );
  }
}

class CombatSkillButton extends StatelessWidget {
  final VoidCallback onTap;
  final BaseActiveSkill skill;
  final bool darkened;

  const CombatSkillButton({
    super.key,
    required this.onTap,
    required this.skill,
    required this.darkened,
  });

  @override
  Widget build(BuildContext context) {
    // A small level badge sits over the button's bottom-right corner —
    // QvSkillButton itself stays level-agnostic (it's also used by the
    // Skills Gear-Up screen and loadout slot cards, neither of which wants
    // this badge baked in), so it's layered on here instead. IgnorePointer
    // keeps the badge from stealing the tap QvSkillButton's own internal
    // GestureDetector would otherwise handle.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        QvSkillButton(
          skillIconPath: skill.data.iconPath,
          onTap: onTap,
          width: 65,
          height: 65,
          skillButtonColor: skill.data.buttonColor,
          darkened: darkened,
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Lv ${skill.level}',
                style: const TextStyle(
                    fontSize: 10, color: Colors.white, height: 1.2),
              ),
            ),
          ),
        ),
      ],
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
                          buttonColor: ButtonColor.getColor(enemyData.rarity),
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
              image: AssetImage(
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
              image: AssetImage(
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
