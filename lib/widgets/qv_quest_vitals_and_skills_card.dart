import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
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
// Also the destination for player/enemy inspection, the flee confirmation,
// and skill targeting — tapping the player or an enemy on the battlefield
// used to slide a separate floating PlayerInfoBox/EnemyInfoBox in over it,
// Flee used to open a QuestFleeConfirmationModal dialog, and tapping a
// skill used to slide a floating TargetEnemySkillBox in on the player's
// side of the battlefield; all four are now this card's own detail content
// instead (_PlayerDetailContent/_EnemyDetailContent/
// _FleeConfirmationContent/_SkillTargetContent below), and the card grows
// upward via AnimatedSize (alignment: bottomCenter, so the card's bottom
// edge — anchored against the nav bar — stays put while its top edge moves
// up) to show them, fully replacing the normal Skills+Vitals content
// rather than appending to it. Per the player's explicit request, this
// growth overlays the battlefield instead of resizing it —
// QuestEncounterView's own Stack reserves this card's `collapsedHeight`
// for the quest-step content behind it and positions this card as a
// separate layer on top, free to grow past that reservation. Tapping an
// enemy still targets it exactly like before (CombatCubit.onEnemyTap is
// unchanged) — only *where* the skill's own info/confirm UI lives moved.
// Potions/Bag stay their own thing for now — see the Skill Cooldown UI
// ticket.
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

  // Fixed height for the player/enemy/flee detail views — drives
  // AnimatedSize's grow-upward animation below. Tuned live in the
  // simulator (comfortably fits _EnemyDetailContent's tallest case)
  // rather than derived, same as every other fixed pixel-art dimension in
  // this UI.
  static const double _detailHeight = 300;

  // _SkillTargetContent's own height — deliberately smaller than
  // _detailHeight: an icon-plus-description row and a confirm/cancel
  // button row need far less room than the other three detail views'
  // portrait/stat-list layouts, and stretching it to match would just
  // leave dead space. Tuned live the same way.
  static const double _skillTargetHeight = 190;

  // This card's own rendered height in its normal (Skills-or-placeholder +
  // vitals) state — QuestEncounterView reads this to reserve exactly that
  // much space for the quest-step content behind it, so this card can grow
  // taller than its normal footprint (via AnimatedSize above) and overlay
  // that content instead of resizing it. Tuned live the same way
  // _detailHeight is; keep in sync if this card's own padding/content ever
  // changes height.
  static const double collapsedHeight = 200;

  @override
  Widget build(BuildContext context) {
    final combatState = this.combatState;
    final isInspectingEnemy = combatState != null &&
        combatState.status == CombatStatus.inspectingEnemy &&
        combatState.inspectingEnemyIndex != -1;
    final isInspectingPlayer = combatState != null &&
        combatState.status == CombatStatus.inspectingPlayer;
    final isConfirmingFlee = combatState != null &&
        combatState.status == CombatStatus.confirmingFlee;
    final isTargetingSkill = combatState != null &&
        combatState.status == CombatStatus.targetingSkill;

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
    } else if (isConfirmingFlee) {
      content = const SizedBox(
          height: _detailHeight, child: _FleeConfirmationContent());
    } else if (isTargetingSkill) {
      content = SizedBox(
        height: _skillTargetHeight,
        child: _SkillTargetContent(
          skill: combatState.targetingSkill!,
          cooldownTimer:
              combatState.skillCooldownFor(combatState.targetingSkill!),
        ),
      );
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
      // Top padding bumped from the original 10 — per feedback,
      // _SkillTargetContent's icon read too close to the top edge. This
      // is the whole card's own padding (every state's content sits
      // inside it, not just the skill-target one), so collapsedHeight
      // below grows by the same 2px this adds.
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
                        darkened:
                            combatState.status == CombatStatus.targetingSkill &&
                                combatState.targetingSkill?.id !=
                                    playerSkills.activeSkillSlot1!.id,
                        cooldownTimer: combatState
                            .skillCooldownFor(playerSkills.activeSkillSlot1!),
                      ),
                    if (playerSkills.activeSkillSlot2 != null)
                      CombatSkillButton(
                        onTap: () => context
                            .read<CombatCubit>()
                            .onSkillButtonTap(
                                context, playerSkills.activeSkillSlot2!),
                        skill: playerSkills.activeSkillSlot2!,
                        darkened:
                            combatState.status == CombatStatus.targetingSkill &&
                                combatState.targetingSkill?.id !=
                                    playerSkills.activeSkillSlot2!.id,
                        cooldownTimer: combatState
                            .skillCooldownFor(playerSkills.activeSkillSlot2!),
                      ),
                    if (playerSkills.activeSkillSlot3 != null)
                      CombatSkillButton(
                        onTap: () => context
                            .read<CombatCubit>()
                            .onSkillButtonTap(
                                context, playerSkills.activeSkillSlot3!),
                        skill: playerSkills.activeSkillSlot3!,
                        darkened:
                            combatState.status == CombatStatus.targetingSkill &&
                                combatState.targetingSkill?.id !=
                                    playerSkills.activeSkillSlot3!.id,
                        cooldownTimer: combatState
                            .skillCooldownFor(playerSkills.activeSkillSlot3!),
                      ),
                    if (playerSkills.activeSkillSlot4 != null)
                      CombatSkillButton(
                        onTap: () => context
                            .read<CombatCubit>()
                            .onSkillButtonTap(
                                context, playerSkills.activeSkillSlot4!),
                        skill: playerSkills.activeSkillSlot4!,
                        darkened:
                            combatState.status == CombatStatus.targetingSkill &&
                                combatState.targetingSkill?.id !=
                                    playerSkills.activeSkillSlot4!.id,
                        cooldownTimer: combatState
                            .skillCooldownFor(playerSkills.activeSkillSlot4!),
                      ),
                    if (playerSkills.activeSkillSlot5 != null)
                      CombatSkillButton(
                        onTap: () => context
                            .read<CombatCubit>()
                            .onSkillButtonTap(
                                context, playerSkills.activeSkillSlot5!),
                        skill: playerSkills.activeSkillSlot5!,
                        darkened:
                            combatState.status == CombatStatus.targetingSkill &&
                                combatState.targetingSkill?.id !=
                                    playerSkills.activeSkillSlot5!.id,
                        cooldownTimer: combatState
                            .skillCooldownFor(playerSkills.activeSkillSlot5!),
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
                    attackTimer:
                        context.read<CombatCubit>().state.attackTimerFor(enemy),
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

// Moved from the old QuestFleeConfirmationModal (a showDialog popup) — same
// copy, minus the dialog-specific chrome (its own centered/fixed-size
// QvMetalCornerBorder card and "x" close icon, both redundant now that this
// renders directly inside QuestVitalsAndSkillsCard's own shell). Cancel and
// Yes/Flee sit side by side at the bottom rather than the old lone "Yes,
// Flee" + a separate "x", matching how a two-way choice reads elsewhere in
// this app (e.g. QvConfirmationModal's own confirm/cancel pairing) — "Yes,
// Flee" alone with only a corner "x" to back out wasn't as discoverable.
class _FleeConfirmationContent extends StatelessWidget {
  const _FleeConfirmationContent();

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text('Would you like to flee?', style: QvTextStyles.heading),
        const SizedBox(height: 8),
        Container(
          height: 2,
          width: MediaQuery.of(context).size.width * 0.7,
          color: colorScheme.secondary,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Center(
            child: Text(
              'Fleeing will end the current quest and return you fully back '
              'to town. You will lose any progress you have made in this '
              'quest but will receive any loot you have collected.',
              style: QvTextStyles.note.copyWith(color: colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: QvButton(
                height: 40,
                buttonColor: ButtonColor.surfaceContainer,
                onTap: () => context.read<CombatCubit>().setIdle(),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: QvTextStyles.title
                        .copyWith(color: colorScheme.onSurface),
                  ),
                ),
              ),
            ),
            Expanded(
              child: QvButton(
                height: 40,
                buttonColor: ButtonColor.primary,
                onTap: () => context.read<QuestEncounterCubit>().fleeQuest(),
                child: Center(
                  child: Text(
                    'Yes, Flee',
                    style: QvTextStyles.title
                        .copyWith(color: colorScheme.secondary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

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

// One "find this, style it differently" rule for _highlightedDescription
// below — pattern's matches get `style` layered on top of the paragraph's
// base style, everything else stays plain.
class _DescriptionHighlight {
  final RegExp pattern;
  final TextStyle style;
  const _DescriptionHighlight(this.pattern, this.style);
}

// Builds a skill's combatDescription into a Text (no highlights) or a
// Text.rich (one or more) — every match of every rule in `highlights` gets
// that rule's style layered over `baseStyle`, everything else stays plain.
// Rules are expected not to overlap (word-boundary element/status names vs.
// a digits-only number pattern never do here); a later rule's match starting
// inside an earlier one's is silently dropped rather than corrupting the
// span order.
Widget _highlightedDescription(
    String text, TextStyle baseStyle, List<_DescriptionHighlight> highlights) {
  if (highlights.isEmpty) {
    return Text(text, style: baseStyle);
  }

  final matches = <MapEntry<Match, TextStyle>>[
    for (final highlight in highlights)
      for (final match in highlight.pattern.allMatches(text))
        MapEntry(match, highlight.style),
  ]..sort((a, b) => a.key.start.compareTo(b.key.start));
  if (matches.isEmpty) {
    return Text(text, style: baseStyle);
  }

  final spans = <TextSpan>[];
  var cursor = 0;
  for (final entry in matches) {
    final match = entry.key;
    if (match.start < cursor) continue;
    if (match.start > cursor) {
      spans.add(TextSpan(text: text.substring(cursor, match.start)));
    }
    spans.add(TextSpan(
        text: text.substring(match.start, match.end), style: entry.value));
    cursor = match.end;
  }
  if (cursor < text.length) {
    spans.add(TextSpan(text: text.substring(cursor)));
  }
  // Text.rich, not a bare RichText — RichText's TextSpan.style is used
  // exactly as given with no DefaultTextStyle merging, so it'd silently
  // drop the app-wide Pixel1 fontFamily (set on MaterialApp's ThemeData,
  // not on QvTextStyles.note itself) that every plain Text picks up
  // through that merge. Text.rich goes through the same DefaultTextStyle
  // merge plain Text does.
  return Text.rich(TextSpan(style: baseStyle, children: spans));
}

// Matches the real, already-computed number combatDescription splices into
// its template (see BaseActiveSkill.combatDescription), wherever it
// directly precedes a damage-type or HP callout — bolded so the number a
// cast will actually deal/grant stands out. Deliberately narrower than "any
// digits in the string": a static rate straight from the template (e.g.
// Firebolt's "20% chance to apply Burn") isn't a per-cast combat-realized
// amount and shouldn't read as one.
final RegExp _combatNumberPattern =
    RegExp(r'\d+(?=\s+(?:Fire Damage|Ice Damage|HP))');

// One highlight rule per element/status name this skill's description can
// mention, built from its own data rather than hardcoded per skill — a
// null color (weaponType's damage type, or a non-elemental status like
// Weakness/Shield) is simply skipped, so a skill with nothing to highlight
// falls back to a plain Text via the empty-list branch above.
List<_DescriptionHighlight> _descriptionHighlights(BaseActiveSkill skill) {
  final damageType = skill.data.damageEffect?.damageType;
  return [
    _DescriptionHighlight(
        _combatNumberPattern, const TextStyle(fontWeight: FontWeight.bold)),
    if (damageType?.color != null)
      _DescriptionHighlight(
        RegExp('\\b${RegExp.escape(damageType!.name)}\\b'),
        TextStyle(color: damageType.color),
      ),
    for (final chance in skill.data.statusEffectChances)
      if (chance.statusEffectType?.color != null)
        _DescriptionHighlight(
          RegExp('\\b${RegExp.escape(chance.statusEffectType!.label)}\\b'),
          TextStyle(color: chance.statusEffectType!.color),
        ),
  ];
}

// Moved from combat_page.dart's old floating TargetEnemySkillBox, laid out
// per the player's own spec instead of that widget's plain top-to-bottom
// stack: the skill's icon sits to the left, its name/level/description/
// cost/effect lines fill the remaining width to the right (wrapped in a
// scrollable — same defensive reasoning as _EnemyDetailContent's stat
// list, a verbose skill description shouldn't be able to overflow this
// card), and a Cancel/Confirm button row sits below, X and check
// (Symbols.close/Symbols.check) rather than text — mirroring
// _FleeConfirmationContent's own Cancel/Yes-Flee pairing but iconic since
// there's much less width to work with alongside the icon+text row above.
// Cancel goes through CombatCubit.setIdle() (clears targetingSkill/target
// exactly like re-tapping the same skill already did); Confirm is the
// same onAttackButtonTap the old "Attack" button called — tapping an
// enemy to (re)target it is untouched, still CombatCubit.onEnemyTap via
// EnemyDisplay in combat_page.dart.
//
// A skill on cooldown can still be selected here (CombatSkillButton's own
// onTap is no longer cooldown-gated — see that class) — Confirm itself is
// what's disabled (QvButton's own onTap: null + darkened, same "disabled"
// idiom used elsewhere) rather than blocking selection entirely, so the
// player can still read a cooling-down skill's description without it
// staying invisible until ready. The live countdown itself moved off the
// icon (which shows no overlay here, unlike the Skills row's own
// CombatSkillButton) and onto the Confirm button, replacing its checkmark
// — one readout for "why can't I cast this," not two.
class _SkillTargetContent extends StatefulWidget {
  final BaseActiveSkill skill;
  final ScheduledTimer? cooldownTimer;
  const _SkillTargetContent({required this.skill, this.cooldownTimer});

  @override
  State<_SkillTargetContent> createState() => _SkillTargetContentState();
}

class _SkillTargetContentState extends State<_SkillTargetContent> {
  // Same live-ticking idiom as _CombatSkillButtonState's own timer — purely
  // display, recomputed from cooldownTimer.nextTriggerAt each second.
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
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final playerCombatStats =
        context.read<PlayerCubit>().state.playerCombatStats;
    if (playerCombatStats == null) {
      return const SizedBox.shrink();
    }
    final skill = widget.skill;
    final timer = widget.cooldownTimer;
    final now = DateTime.now();
    final remaining = timer != null && timer.nextTriggerAt.isAfter(now)
        ? timer.nextTriggerAt.difference(now)
        : null;
    final onCooldown = remaining != null;

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  // No countdown overlay on the icon here (unlike the
                  // Skills row's own CombatSkillButton) — per feedback, the
                  // active countdown now lives on the Confirm button below
                  // instead, replacing its checkmark, so it isn't shown
                  // twice.
                  QvSkillButton(
                    skillIconPath: skill.data.iconPath,
                    skillButtonColor: skill.data.buttonColor,
                    width: 65,
                    height: 65,
                    darkened: onCooldown,
                  ),
                  const SizedBox(height: 8),
                  // Cost/cooldown moved here from the description column,
                  // per feedback — reads as a property of the skill/icon
                  // itself rather than another description-column line.
                  // Back to one shared QvInsetBackground with a thin
                  // primary-colored divider (rather than two separate
                  // boxes) now that it's using QvBarSize.small's shorter
                  // 20px-minimum border — at that size the combined box no
                  // longer reads oversized the way it did against the
                  // standard 36px-minimum border early on.
                  QvInsetBackground(
                    width: 54,
                    type: QvInsetBackgroundType.surfaceContainer,
                    size: QvBarSize.small,
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      children: [
                        Text('${skill.data.apCost ?? 0} AP',
                            textAlign: TextAlign.center,
                            style: QvTextStyles.note
                                .copyWith(color: colorScheme.onSurface)),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Center(
                            child: Container(
                              width: 24,
                              height: 2,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        Text(_cooldownText(skill.data.cooldown),
                            textAlign: TextAlign.center,
                            style: QvTextStyles.note
                                .copyWith(color: colorScheme.onSurface)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QvFadingScrollable(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(skill.data.name,
                                  style: QvTextStyles.sectionTitle
                                      .copyWith(color: colorScheme.onSurface)),
                            ),
                            Text('Lv ${skill.level}',
                                style: QvTextStyles.micro.copyWith(
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.75))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Combat-realized text, not the plain 'x%' template
                        // the Skills Gear-Up screen's `description` shows —
                        // this screen has a real caster to compute against,
                        // so the description itself carries the actual
                        // number a cast will deal/grant (e.g. "dealing 3
                        // Fire Damage per mote consumed") instead of a
                        // separate "Fire Damage: 3" line underneath it. The
                        // damage type's and any status effect's own name
                        // are highlighted in their color, and the
                        // combat-realized number itself is bolded — see
                        // _descriptionHighlights/_highlightedDescription's
                        // own doc comments for the exact matching rules.
                        _highlightedDescription(
                          skill.combatDescription(playerCombatStats),
                          QvTextStyles.note.copyWith(
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.85)),
                          _descriptionHighlights(skill),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: QvButton(
                height: 40,
                buttonColor: ButtonColor.surfaceContainer,
                onTap: () => context.read<CombatCubit>().setIdle(),
                child: Center(
                  child: Icon(Symbols.close,
                      color: colorScheme.onSurface, size: 24),
                ),
              ),
            ),
            Expanded(
              child: QvButton(
                height: 40,
                buttonColor: ButtonColor.primary,
                darkened: onCooldown,
                // Passing null (rather than a no-op closure) also drops
                // QvButton's own press-down animation, so a cooling-down
                // skill's Confirm button doesn't even flash pressed —
                // reads as truly inert, not just "does nothing."
                onTap: onCooldown
                    ? null
                    : () =>
                        context.read<CombatCubit>().onAttackButtonTap(context),
                // The active cooldown countdown lives here instead of as an
                // overlay on the icon above (see that Stack's own removal)
                // — reads more directly as "why this button is disabled"
                // than a second, separate timer readout would.
                child: Center(
                  child: onCooldown
                      ? Text(
                          DataFormatters.formatCountdown(remaining),
                          textAlign: TextAlign.center,
                          style: QvTextStyles.itemTitle.copyWith(
                            color: Colors.white,
                          ),
                        )
                      : Icon(Symbols.check,
                          color: colorScheme.secondary, size: 24),
                ),
              ),
            ),
          ],
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
          // Tappable even on cooldown now — selecting it opens
          // _SkillTargetContent same as any other skill (icon + live
          // countdown carried over there too), which disables its own
          // Confirm button instead of blocking selection at this level.
          // Previously untappable here, which hid a cooling-down skill's
          // description/effects entirely until it was ready.
          onTap: widget.onTap,
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
