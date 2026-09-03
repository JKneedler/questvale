import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/nav_cubit.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/world_tab/questing/chest_loot/chest_loot_page.dart';
import 'package:questvale/cubits/world_tab/questing/combat/combat_cubit.dart';
import 'package:questvale/cubits/world_tab/questing/combat/combat_page.dart';
import 'package:questvale/cubits/world_tab/questing/combat/combat_state.dart';
import 'package:questvale/cubits/world_tab/questing/combat_loot/combat_loot_page.dart';
import 'package:questvale/cubits/world_tab/questing/quest_encounter/background_page.dart';
import 'package:questvale/cubits/world_tab/questing/quest_encounter/chest_encounter_page.dart';
import 'package:questvale/cubits/world_tab/questing/quest_encounter/quest_encounter_cubit.dart';
import 'package:questvale/cubits/world_tab/questing/quest_encounter/quest_encounter_state.dart';
import 'package:questvale/cubits/world_tab/questing/quest_loot/quest_loot_page.dart';
import 'package:questvale/cubits/world_tab/world_cubit.dart';
import 'package:questvale/data/models/quest.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/widgets/qv_quest_encounter_header.dart';
import 'package:questvale/widgets/qv_quest_vitals_and_skills_card.dart';
import 'package:sqflite/sqflite.dart';
import 'package:jk_pixel_ui/jk_pixel_ui.dart';

class QuestEncounterPage extends StatelessWidget {
  const QuestEncounterPage({super.key, required this.quest});
  final Quest quest;

  @override
  Widget build(BuildContext context) {
    final gameData = context.read<GameData>();
    final questZones = gameData.questZones;
    final questZone = questZones.firstWhere((zone) => zone.id == quest.zoneId);
    return BlocProvider<QuestEncounterCubit>(
      create: (context) => QuestEncounterCubit(
        quest: quest,
        initialQuestStatus: QuestStatus.questBegin,
        db: context.read<Database>(),
        gameData: gameData,
        questZone: questZone,
      ),
      child: QuestEncounterView(),
    );
  }
}

// StatefulWidget purely to hook NavBar's own useCombatBackground over this
// view's whole mounted lifetime — see NavState.showCombatNavBackground's
// own doc comment. That toggle used to be scoped to live combat only
// (CombatPage's own State), but now spans the entire quest-encounter flow,
// matching QuestVitalsAndSkillsCard below being a constant presence too —
// NavCubit is captured once in initState rather than re-read via context in
// dispose, since reading InheritedWidgets from a State that's already
// mid-teardown is fragile; a plain captured reference isn't. The toggle-on
// call is deferred a frame (addPostFrameCallback) because emitting into
// NavCubit synchronously from initState — while this exact frame's build is
// still in progress — risks flutter_bloc's BlocBuilder above (HomeView's
// own) calling setState mid-build; the mounted check guards the rare case
// where this view unmounts again before that deferred callback fires.
class QuestEncounterView extends StatefulWidget {
  const QuestEncounterView({super.key});

  @override
  State<QuestEncounterView> createState() => _QuestEncounterViewState();
}

class _QuestEncounterViewState extends State<QuestEncounterView> {
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

  Widget _getQuestView(BuildContext context, QuestEncounterState questState) {
    final encounter = questState.encounter;
    if (questState.questStatus == QuestStatus.questBegin) {
      return SizedBox(child: Text('Quest Begin'));
    } else if (questState.questStatus == QuestStatus.floorBegin) {
      return SizedBox(child: Text('Floor Begin'));
    } else if (questState.questStatus == QuestStatus.encounterInProgress) {
      if (encounter != null) {
        if (encounter.encounterType.isCombatEncounter()) {
          // CombatCubit is provided above this view's whole body (see
          // build()) rather than by CombatView itself, so it can also
          // reach QuestVitalsAndSkillsCard sitting outside this swapped
          // region — CombatView just consumes it.
          return CombatView(key: const ValueKey('combatPage'));
        } else if (encounter.encounterType.isChestEncounter()) {
          return ChestEncounterPage(
            rarity: encounter.chestRarity ?? Rarity.common,
            firstPlay: false,
            key: const ValueKey('chestEncounterPage'),
          );
        } else {
          return SizedBox();
        }
      } else {
        return SizedBox();
      }
    } else if (questState.questStatus == QuestStatus.encounterCompleted) {
      if (encounter != null) {
        if (encounter.encounterType.isCombatEncounter()) {
          return CombatLootPage(key: const ValueKey('combatLootPage'));
        } else if (encounter.encounterType.isChestEncounter()) {
          return ChestLootPage(key: const ValueKey('chestLootPage'));
        } else {
          return SizedBox();
        }
      } else {
        return SizedBox();
      }
    } else if (questState.questStatus == QuestStatus.questCompleted) {
      return QuestLootPage(key: const ValueKey('questLootPage'));
    }
    return SizedBox();
  }

  // TODO
  QvAnimatedTransitionType getTransitionType(QuestEncounterState questState) {
    if (questState.questStatus == QuestStatus.encounterCompleted) {
      return QvAnimatedTransitionType.fade;
    }
    return QvAnimatedTransitionType.slideLeft;
  }

  // TODO
  Duration getTransitionDuration(QuestEncounterState questState) {
    final encounter = questState.encounter;
    if (encounter == null) {
      return const Duration(milliseconds: 0);
    }
    if (encounter.completedAt != null) {
      return const Duration(milliseconds: 400);
    }
    return const Duration(milliseconds: 600);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuestEncounterCubit, QuestEncounterState>(
      builder: (context, questState) {
        // True only while a live combat encounter is actually in progress
        // (not its loot page, not chest encounters) — used both for
        // QvQuestEncounterHeader's own capBottom (see its doc comment) and
        // to decide whether a CombatCubit exists to provide/read below.
        final isLiveCombat = questState.questStatus ==
                QuestStatus.encounterInProgress &&
            (questState.encounter?.encounterType.isCombatEncounter() ?? false);

        final playerState = context.watch<PlayerCubit>().state;
        final character = playerState.character;
        final playerSkills = playerState.playerSkills;

        // QuestVitalsAndSkillsCard is a constant presence across the whole
        // quest-encounter flow (see its own doc comment) — sits below the
        // swapped _getQuestView content rather than inside it, so it never
        // slides/fades on transitions between quest steps the way that
        // content does. combatState is only non-null while isLiveCombat —
        // everywhere else the card renders its own placeholder in place of
        // the Skills row. Guards on character/playerSkills being loaded the
        // same way the old CombatView-local check did — in practice always
        // true here since HomeView's own IndexedStack doesn't mount this
        // page until PlayerCubit has a character.
        final vitalsPanel = character == null || playerSkills == null
            ? const SizedBox.shrink()
            : isLiveCombat
                ? BlocBuilder<CombatCubit, CombatState>(
                    builder: (context, combatState) => QuestVitalsAndSkillsCard(
                      character: character,
                      mageMotes: playerState.mageMotes,
                      playerSkills: playerSkills,
                      combatState: combatState,
                    ),
                  )
                : QuestVitalsAndSkillsCard(
                    character: character,
                    mageMotes: playerState.mageMotes,
                    playerSkills: playerSkills,
                    combatState: null,
                  );

        Widget body = MultiBlocListener(
          listeners: [
            BlocListener<QuestEncounterCubit, QuestEncounterState>(
              listenWhen: (prev, next) =>
                  next.questStatus == QuestStatus.encounterDeleted,
              listener: (context, questState) {
                context.read<WorldCubit>().loadQuest();
              },
            ),
            BlocListener<QuestEncounterCubit, QuestEncounterState>(
              listenWhen: (prev, next) =>
                  next.questStatus == QuestStatus.questDeleted,
              listener: (context, questState) {
                context.read<WorldCubit>().onQuestFinished();
              },
            ),
            BlocListener<QuestEncounterCubit, QuestEncounterState>(
              listenWhen: (prev, next) => next.questStatus != prev.questStatus,
              listener: (context, questState) {
                context.read<PlayerCubit>().loadCharacter();
              },
            ),
          ],
          child: BackgroundPage(
            zoneName: context.read<QuestEncounterCubit>().questZone.name,
            darkened: questState.darkened,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  questState.questStatus == QuestStatus.encounterInProgress ||
                          questState.questStatus ==
                              QuestStatus.encounterCompleted
                      ? QvQuestEncounterHeader(
                          darkened: questState.darkened,
                          curEncounterNum: questState.quest.curEncounterNum,
                          numEncountersCurFloor:
                              questState.quest.numEncountersCurFloor,
                          capBottom: !isLiveCombat,
                        )
                      // Preserves the top clearance BackgroundPage's own
                      // padding used to provide unconditionally — see its
                      // doc comment — for the states that don't show the
                      // header (and its own top filler bar) at all.
                      : const SizedBox(
                          height: QvQuestEncounterHeader.topFillerHeight),
                  Expanded(
                    child: QvAnimatedTransition(
                      duration: getTransitionDuration(questState),
                      type: getTransitionType(questState),
                      child: _getQuestView(context, questState),
                    ),
                  ),
                  const SizedBox(height: 10),
                  vitalsPanel,
                ],
              ),
            ),
          ),
        );

        // CombatCubit lives here — one level above both the swapped
        // CombatView content and the persistent vitalsPanel above — rather
        // than being created by CombatView itself, so the panel can read
        // it too. Keyed by encounter id (rather than relying on
        // _getQuestView returning a different widget type in between, as
        // the old CombatPage's own static key effectively did) so a fresh
        // CombatCubit is created per combat encounter and disposed the
        // instant combat isn't live, regardless of what other quest steps
        // run in between.
        if (isLiveCombat) {
          body = BlocProvider<CombatCubit>(
            key: ValueKey('combat-${questState.encounter!.id}'),
            create: (context) => CombatCubit(
              encounterId: questState.encounter!.id,
              questZone: context.read<QuestEncounterCubit>().questZone,
              playerCubit: context.read<PlayerCubit>(),
              db: context.read<Database>(),
            ),
            child: body,
          );
        }

        return body;
      },
    );
  }
}
