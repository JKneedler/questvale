import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_state.dart';
import 'package:questvale/cubits/world_tab/questing/combat/combat_cubit.dart';
import 'package:questvale/cubits/world_tab/questing/combat/combat_state.dart';
import 'package:questvale/cubits/world_tab/questing/quest_encounter/quest_encounter_cubit.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/mage_motes.dart';
import 'package:questvale/data/models/scheduled_timer.dart';
import 'package:questvale/data/providers/game_data_models/enemy_attack_data.dart';
import 'package:questvale/data/providers/game_data_models/enemy_data.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/helpers/data_formatters.dart';
import 'package:questvale/helpers/shared_enums.dart';
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
// A persistent element for the *entire* quest-encounter flow (see
// QuestEncounterView, which mounts this once alongside BackgroundPage
// rather than it living inside CombatPage/CombatView) — not just live
// combat, so its content adapts around `combatState`, which is only
// non-null while a live combat encounter is actually in progress (see
// QuestEncounterView's own doc comment for how that's wired).
//
// Also the destination for player/enemy inspection — tapping the player or
// an enemy on the battlefield (BattleFieldDisplay, combat_page.dart) used
// to slide a separate floating PlayerInfoBox/EnemyInfoBox in over the
// battlefield; those are now this card's own detail content instead
// (_PlayerDetailContent/_EnemyDetailContent below), and the card grows
// upward via AnimatedSize (alignment: bottomCenter, so the card's bottom
// edge — anchored against the nav bar — stays put while its top edge moves
// up) to show them, fully replacing the normal Skills+Vitals content
// rather than appending to it. The battlefield's own Expanded region above
// this card shrinks to match automatically — plain Column/Expanded layout,
// no stacking/z-index needed, since this card is a fixed-size sibling
// after that Expanded in QuestEncounterView's own Column. Skill-targeting
// (TargetEnemySkillBox) and the other planned moves (Flee/Potions/Bag)
// stay as their own thing for now — see the Skill Cooldown UI ticket.
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

  // Fixed height for both detail views — drives AnimatedSize's grow-upward
  // animation below. Tuned live in the simulator (comfortably fits
  // _EnemyDetailContent's tallest case) rather than derived, same as every
  // other fixed pixel-art dimension in this UI.
  static const double _detailHeight = 300;

  // This card's own rendered height in its normal (Skills-or-placeholder +
  // vitals) state — QuestEncounterView reads this to reserve exactly that
  // much space for the quest-step content behind it, so this card can grow
  // taller than its normal footprint (via AnimatedSize above) and overlay
  // that content instead of resizing it. Tuned live the same way
  // _detailHeight is; keep in sync if this card's own padding/content ever
  // changes height.
  static const double collapsedHeight = 198;

  @override
  Widget build(BuildContext context) {
    final combatState = this.combatState;
    final isInspectingEnemy = combatState != null &&
        combatState.status == CombatStatus.inspectingEnemy &&
        combatState.inspectingEnemyIndex != -1;
    final isInspectingPlayer = combatState != null &&
        combatState.status == CombatStatus.inspectingPlayer;

    final Widget content;
    if (isInspectingEnemy) {
      content = SizedBox(
        height: _detailHeight,
        child: _EnemyDetailContent(
            enemy: combatState.enemies[combatState.inspectingEnemyIndex]),
      );
    } else if (isInspectingPlayer) {
      content =
          const SizedBox(height: _detailHeight, child: _PlayerDetailContent());
    } else {
      content = _NormalContent(
        character: character,
        mageMotes: mageMotes,
        playerSkills: playerSkills,
        combatState: combatState,
      );
    }

    return QvBackground(
      width: double.infinity,
      type: QvBackgroundType.surfaceNoBottom,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: Alignment.bottomCenter,
        child: content,
      ),
    );
  }
}

// The card's default content — Skills (or, outside live combat, a plain
// placeholder — see QuestVitalsAndSkillsCard's own doc comment) above
// health/motes. Pulled out to its own widget purely so
// QuestVitalsAndSkillsCard.build can swap it for a detail view without a
// deeply-nested inline conditional.
class _NormalContent extends StatelessWidget {
  const _NormalContent({
    required this.character,
    required this.mageMotes,
    required this.playerSkills,
    required this.combatState,
  });

  final Character character;
  final MageMotes? mageMotes;
  final PlayerSkills playerSkills;
  final CombatState? combatState;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final combatState = this.combatState;
    return Column(
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
    );
  }
}

// Moved from combat_page.dart's old floating EnemyInfoBox — same content
// (portrait/rarity border, name pill, HP bar, next-attack countdown,
// status effects, stat lines, Close), minus the outer Padding + full-size
// QvButton(surfaceContainer) shell that used to make it read as its own
// floating card. It renders directly inside QuestVitalsAndSkillsCard's own
// QvBackground shell/padding now, so that wrapper would just be a
// redundant second border.
class _EnemyDetailContent extends StatelessWidget {
  final Enemy enemy;

  const _EnemyDetailContent({required this.enemy});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final enemyData = context
        .read<QuestEncounterCubit>()
        .questZone
        .enemies
        .firstWhere((enemyData) => enemyData.id == enemy.enemyDataId);
    return Column(
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
                        insetBackgroundType: QvInsetBackgroundType.secondary,
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
                  _EnemyNextAttackSlice(
                    attackTimer: context
                        .read<CombatCubit>()
                        .state
                        .attackTimerFor(enemy),
                    enemyData: enemyData,
                  ),
                  _EnemyStatusEffectsSlice(),
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
            style: QvTextStyles.title.copyWith(color: colorScheme.secondary),
          )),
        ),
      ],
    );
  }
}

class _EnemyNextAttackSlice extends StatefulWidget {
  final ScheduledTimer? attackTimer;
  final EnemyData enemyData;

  const _EnemyNextAttackSlice(
      {required this.attackTimer, required this.enemyData});

  @override
  State<_EnemyNextAttackSlice> createState() => _EnemyNextAttackSliceState();
}

class _EnemyNextAttackSliceState extends State<_EnemyNextAttackSlice> {
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

class _EnemyStatusEffectsSlice extends StatelessWidget {
  const _EnemyStatusEffectsSlice();

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

// Moved from combat_page.dart's old floating PlayerInfoBox — still the same
// bare stub (just "Player" + Close); real player detail content is its own
// future pass, this is purely the relocation.
class _PlayerDetailContent extends StatelessWidget {
  const _PlayerDetailContent();

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
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
            style: QvTextStyles.title.copyWith(color: colorScheme.secondary),
          )),
        ),
      ],
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
  // reloads — display-only, same pattern as _EnemyNextAttackSlice's own
  // timer above. Nothing needs to be reconciled when a cooldown actually
  // expires (unlike an enemy attack timer), so this never calls
  // CombatCubit.reload() itself — the next real reload picks up the DB
  // state naturally.
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
