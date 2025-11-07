import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/character_data_cubit.dart';
import 'package:questvale/cubits/town_tab/questing/combat_encounter/combat_encounter_cubit.dart';
import 'package:questvale/cubits/town_tab/questing/combat_encounter/combat_encounter_state.dart';
import 'package:questvale/cubits/town_tab/questing/quest_encounter/quest_bag_inventory_modal.dart';
import 'package:questvale/cubits/town_tab/questing/quest_encounter/quest_encounter_cubit.dart';
import 'package:questvale/cubits/town_tab/questing/quest_encounter/quest_encounter_state.dart';
import 'package:questvale/cubits/town_tab/questing/quest_encounter/quest_flee_confirmation_modal.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/providers/game_data_models/enemy_data.dart';
import 'package:questvale/data/providers/game_data_models/quest_zone.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/widgets/qv_blinking.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_enemy_info_modal.dart';
import 'package:questvale/widgets/qv_primary_border.dart';
import 'package:questvale/widgets/qv_skill_button.dart';
import 'package:sqflite/sqflite.dart';

class CombatEncounterPage extends StatelessWidget {
  const CombatEncounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuestEncounterCubit, QuestEncounterState>(
        builder: (context, questEncounterState) {
      final encounter = questEncounterState.encounter;
      if (encounter == null) {
        return const SizedBox.shrink();
      }
      return BlocProvider<CombatEncounterCubit>(
        create: (context) => CombatEncounterCubit(
            encounter: encounter,
            character: context.read<CharacterDataCubit>().state.character!,
            db: context.read<Database>()),
        child: const CombatEncounterView(),
      );
    });
  }
}

class CombatEncounterView extends StatelessWidget {
  const CombatEncounterView({super.key});

  Alignment getAlignment(int index, int totalEnemies) {
    if (totalEnemies == 3) {
      return index == 1 ? Alignment.topCenter : Alignment.bottomCenter;
    } else {
      return Alignment.bottomCenter;
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<CombatEncounterCubit, CombatEncounterState>(
        builder: (context, combatEncounterState) {
      final combatStats = context.watch<CharacterDataCubit>().state.combatStats;
      final zone = context.read<QuestEncounterCubit>().questZone;
      return BlocListener<CombatEncounterCubit, CombatEncounterState>(
        listenWhen: (prev, next) =>
            prev.status != CombatEncounterStatus.complete &&
            next.status == CombatEncounterStatus.complete,
        listener: (context, combatEncounterState) async {
          if (combatEncounterState.status == CombatEncounterStatus.complete) {
            if (context.read<CombatEncounterCubit>().encounter.completedAt ==
                null) {
              await context.read<QuestEncounterCubit>().completeEncounter();
            }
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context
              .read<CombatEncounterCubit>()
              .removeHighlightedElement(context),
          child: Column(
            children: [
              SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var i = 0;
                        i < combatEncounterState.enemies.length;
                        i++)
                      EnemyView(
                        zone: zone,
                        firstPlay: true,
                        onTap: () => context
                            .read<CombatEncounterCubit>()
                            .onEnemyButtonTap(context, i),
                        enemy: combatEncounterState.enemies[i],
                        alignment: getAlignment(
                            i, combatEncounterState.enemies.length),
                        isDarkened: !(combatEncounterState.status ==
                                CombatEncounterStatus.getEnemyStatus(i) ||
                            combatEncounterState.status ==
                                CombatEncounterStatus.idle ||
                            combatEncounterState.status.isTargetSelectStatus()),
                        isGlowing:
                            combatEncounterState.target.getEnemyIndex() == i ||
                                combatEncounterState.target ==
                                    CombatEncounterTarget.all,
                      ),
                  ],
                ),
              ),
              if (combatEncounterState.status.isEnemyStatus())
                EnemyInfoPanel(
                    enemyData: zone.enemies.firstWhere((enemyData) =>
                        enemyData.id ==
                        combatEncounterState
                            .enemies[
                                combatEncounterState.status.getEnemyIndex()]
                            .enemyDataId),
                    enemy: combatEncounterState
                        .enemies[combatEncounterState.status.getEnemyIndex()]),
              Expanded(child: SizedBox()),
              if (combatEncounterState.status ==
                  CombatEncounterStatus.targetSelectBasicAttack)
                BasicAttackTargetSelectPanel(
                  hasTarget:
                      combatEncounterState.target != CombatEncounterTarget.none,
                  damage: combatStats?.physicalBaseDamage ?? 0,
                  damageType:
                      combatStats?.basicAttackDamageType ?? DamageType.physical,
                ),
              if (combatEncounterState.status.isTargetSelectSkillStatus())
                SkillTargetSelectPanel(
                  hasTarget:
                      combatEncounterState.target != CombatEncounterTarget.none,
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  height: 180,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            height: 80,
                            child: Row(
                              children: [
                                CombatSkillButton(
                                  currentStatus: combatEncounterState.status,
                                  onTap: () => context
                                      .read<CombatEncounterCubit>()
                                      .onSkillButtonTap(context, 0),
                                  skillIndex: 0,
                                  color: ButtonColor.uncommon,
                                ),
                                SizedBox(width: 20),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: CombatSkillButton(
                                    currentStatus: combatEncounterState.status,
                                    onTap: () => context
                                        .read<CombatEncounterCubit>()
                                        .onSkillButtonTap(context, 1),
                                    skillIndex: 1,
                                    color: ButtonColor.rare,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          QvButton(
                            darkened: combatEncounterState.status !=
                                CombatEncounterStatus.idle,
                            onTap: () {
                              if (combatEncounterState.status ==
                                  CombatEncounterStatus.idle) {
                                QuestBagInventoryModal.showModal(context);
                              } else {
                                context
                                    .read<CombatEncounterCubit>()
                                    .removeHighlightedElement(context);
                              }
                            },
                            width: MediaQuery.of(context).size.width * 0.35,
                            height: 70,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: ColorFiltered(
                                      colorFilter:
                                          combatEncounterState.status !=
                                                  CombatEncounterStatus.idle
                                              ? ColorFilter.mode(
                                                  Colors.black
                                                      .withValues(alpha: 0.5),
                                                  BlendMode.srcATop)
                                              : const ColorFilter.mode(
                                                  Colors.transparent,
                                                  BlendMode.color),
                                      child: Image.asset(
                                        'images/pixel-icons/bag.png',
                                        filterQuality: FilterQuality.none,
                                        width: 30,
                                        height: 30,
                                        scale: .08,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Bag',
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: colorScheme.secondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          QvButton(
                            darkened: combatEncounterState.status !=
                                    CombatEncounterStatus.idle &&
                                combatEncounterState.status !=
                                    CombatEncounterStatus
                                        .targetSelectBasicAttack,
                            onTap: () => context
                                .read<CombatEncounterCubit>()
                                .onBasicAttackButtonTap(context),
                            height: 100,
                            width: 80,
                            buttonColor: ButtonColor.surface,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 40,
                                  width: 28,
                                  child: ColorFiltered(
                                    colorFilter: combatEncounterState.status !=
                                                CombatEncounterStatus.idle &&
                                            combatEncounterState.status !=
                                                CombatEncounterStatus
                                                    .targetSelectBasicAttack
                                        ? ColorFilter.mode(
                                            Colors.black.withValues(alpha: 0.5),
                                            BlendMode.srcATop)
                                        : const ColorFilter.mode(
                                            Colors.transparent,
                                            BlendMode.color),
                                    child: Image.asset(
                                      'images/pixel-icons/crossed-swords.png',
                                      filterQuality: FilterQuality.none,
                                      scale: .08,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Basic \nAttack',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: combatEncounterState.status !=
                                                CombatEncounterStatus.idle &&
                                            combatEncounterState.status !=
                                                CombatEncounterStatus
                                                    .targetSelectBasicAttack
                                        ? colorScheme.onSurface
                                            .withValues(alpha: 0.5)
                                        : colorScheme.onSurface,
                                    height: 1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      'images/ui/buttons/primary-button-no-bottom-2x.png'),
                                  centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                                  fit: BoxFit.fill,
                                  colorFilter: combatEncounterState.status !=
                                              CombatEncounterStatus.idle &&
                                          !combatEncounterState.status
                                              .isTargetSelectStatus()
                                      ? ColorFilter.mode(
                                          Colors.black.withValues(alpha: 0.5),
                                          BlendMode.srcATop)
                                      : null,
                                ),
                              ),
                              width: 80,
                              height: combatEncounterState.status
                                      .isTargetSelectStatus()
                                  ? 80
                                  : 50,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 12,
                                      child: Text(
                                        'AP',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: colorScheme.secondary,
                                          height: 1,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 30,
                                      child: Text(
                                        '20',
                                        style: TextStyle(
                                          fontSize: 36,
                                          color: colorScheme.secondary,
                                          height: 1,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    if (combatEncounterState.status
                                        .isTargetSelectStatus())
                                      SizedBox(
                                        height: 30,
                                        child: Text(
                                          '(-1)',
                                          style: TextStyle(
                                            fontSize: 36,
                                            color: Colors.red,
                                            height: 1,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            height: 80,
                            child: Row(
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: CombatSkillButton(
                                    currentStatus: combatEncounterState.status,
                                    onTap: () => context
                                        .read<CombatEncounterCubit>()
                                        .onSkillButtonTap(context, 2),
                                    skillIndex: 2,
                                    color: ButtonColor.epic,
                                  ),
                                ),
                                SizedBox(width: 20),
                                CombatSkillButton(
                                  currentStatus: combatEncounterState.status,
                                  onTap: () => context
                                      .read<CombatEncounterCubit>()
                                      .onSkillButtonTap(context, 3),
                                  skillIndex: 3,
                                  color: ButtonColor.legendary,
                                ),
                              ],
                            ),
                          ),
                          QvButton(
                            darkened: combatEncounterState.status !=
                                CombatEncounterStatus.idle,
                            onTap: () {
                              if (combatEncounterState.status ==
                                  CombatEncounterStatus.idle) {
                                QuestFleeConfirmationModal.showModal(
                                    context,
                                    () => context
                                        .read<QuestEncounterCubit>()
                                        .fleeQuest());
                              } else {
                                context
                                    .read<CombatEncounterCubit>()
                                    .removeHighlightedElement(context);
                              }
                            },
                            width: MediaQuery.of(context).size.width * 0.35,
                            height: 70,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Flee',
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: colorScheme.secondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: ColorFiltered(
                                      colorFilter:
                                          combatEncounterState.status !=
                                                  CombatEncounterStatus.idle
                                              ? ColorFilter.mode(
                                                  Colors.black
                                                      .withValues(alpha: 0.5),
                                                  BlendMode.srcATop)
                                              : const ColorFilter.mode(
                                                  Colors.transparent,
                                                  BlendMode.color),
                                      child: Image.asset(
                                        'images/pixel-icons/running-man.png',
                                        filterQuality: FilterQuality.none,
                                        width: 30,
                                        height: 30,
                                        scale: .08,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class EnemyView extends StatelessWidget {
  final Enemy enemy;
  final Alignment alignment;
  final bool isDarkened;
  final VoidCallback onTap;
  final bool isGlowing;
  final bool firstPlay;
  final QuestZone zone;

  const EnemyView({
    super.key,
    required this.enemy,
    this.alignment = Alignment.center,
    this.isDarkened = false,
    required this.onTap,
    this.isGlowing = false,
    this.firstPlay = false,
    required this.zone,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final enemyData = zone.enemies
        .firstWhere((enemyData) => enemyData.id == enemy.enemyDataId);

    return Align(
      alignment: alignment,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        height: 220,
        child: Column(
          children: [
            GestureDetector(
              onTap: onTap,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                height: 180,
                child: Stack(
                  children: [
                    Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.9,
                        heightFactor: 0.9,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'images/backgrounds/${zone.id.toLowerCase()}-mini.png'),
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.none,
                              colorFilter: isDarkened
                                  ? ColorFilter.mode(
                                      Colors.black.withValues(alpha: 0.5),
                                      BlendMode.srcATop)
                                  : null,
                            ),
                            boxShadow: isGlowing
                                ? [
                                    BoxShadow(
                                      color: const Color.fromARGB(
                                          255, 255, 188, 33),
                                      blurRadius: 20,
                                      spreadRadius: 10,
                                      blurStyle: BlurStyle.normal,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ColorFiltered(
                                  colorFilter: isDarkened
                                      ? ColorFilter.mode(
                                          Colors.black.withValues(alpha: 0.5),
                                          BlendMode.srcATop)
                                      : const ColorFilter.mode(
                                          Colors.transparent, BlendMode.color),
                                  child: Image.asset(
                                    'images/enemies/${enemyData.id.toLowerCase()}.png',
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.none,
                                  ),
                                ),
                              ),
                              Container(
                                height: 2,
                                color: colorScheme.secondary,
                              ),
                              Container(
                                height: 18,
                                color: colorScheme.surface,
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                        widthFactor: enemy.currentHealth /
                                            enemyData.health,
                                        child: Container(
                                          height: 18,
                                          color: isDarkened
                                              ? Color(0xffFF4646)
                                                  .withValues(alpha: 0.5)
                                              : Color(0xffFF4646),
                                        ),
                                      ),
                                    ),
                                    Center(
                                        child: Text(
                                      '${enemy.currentHealth} / ${enemyData.health}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          height: 1),
                                    )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        foregroundDecoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'images/ui/borders/${enemyData.rarity.name.toLowerCase()}-border-mini-2x.png'),
                            centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                            fit: BoxFit.fill,
                            filterQuality: FilterQuality.none,
                            colorFilter: isDarkened
                                ? ColorFilter.mode(
                                    Colors.black.withValues(alpha: 0.5),
                                    BlendMode.srcATop)
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            QvButton(
              onTap: onTap,
              darkened: isDarkened,
              height: 36,
              width: MediaQuery.of(context).size.width * 0.25,
              buttonColor: ButtonColor.getColor(enemyData.rarity),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ColorFiltered(
                      colorFilter: isDarkened
                          ? ColorFilter.mode(
                              Colors.black.withValues(alpha: 0.5),
                              BlendMode.srcATop)
                          : const ColorFilter.mode(
                              Colors.transparent, BlendMode.color),
                      child: Image.asset('images/pixel-icons/attack.png',
                          width: 16,
                          height: 16,
                          scale: .08,
                          filterQuality: FilterQuality.none),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '6:12',
                      style: TextStyle(
                          fontSize: 20,
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CombatSkillButton extends StatelessWidget {
  final CombatEncounterStatus currentStatus;
  final VoidCallback onTap;
  final bool darkened;
  final int skillIndex;
  final ButtonColor color;

  const CombatSkillButton({
    super.key,
    required this.currentStatus,
    required this.onTap,
    this.darkened = false,
    required this.skillIndex,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    // return QvButton(
    //   darkened: currentStatus != CombatEncounterStatus.idle &&
    //       currentStatus != CombatEncounterStatus.getSkillStatus(skillIndex),
    //   onTap: onTap,
    //   width: 56,
    //   height: 56,
    //   buttonColor: color,
    //   child: Center(
    //     child: Text(
    //       '${skillIndex + 1}',
    //       style: TextStyle(fontSize: 30, color: colorScheme.secondary),
    //     ),
    //   ),
    // );
    return QvSkillButton(
      skillIconPath: 'images/skills/ice_spike.png',
      onTap: onTap,
      width: 64,
      height: 64,
      skillButtonColor: SkillButtonColor.iceBlue,
    );
  }
}

class EnemyInfoPanel extends StatelessWidget {
  final Enemy enemy;
  final EnemyData enemyData;
  const EnemyInfoPanel(
      {super.key, required this.enemy, required this.enemyData});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 180,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: QvPrimaryBorder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    enemyData.name,
                    style: TextStyle(
                      fontSize: 20,
                      color: colorScheme.onSurface,
                      height: 1.2,
                    ),
                  ),
                  Container(
                    height: 1.5,
                    color: colorScheme.primary,
                  ),
                  SizedBox(
                    height: 120,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            height: 18,
                            width: double.infinity,
                            child: Row(
                              children: [
                                Text(
                                  'NEXT',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.primary,
                                    height: 1,
                                  ),
                                ),
                                SizedBox(width: 50),
                                Text(
                                  'ETA',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.primary,
                                    height: 1,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  'DMG',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.primary,
                                    height: 1,
                                  ),
                                ),
                                SizedBox(width: 24),
                                Text(
                                  'TYPE',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.primary,
                                    height: 1,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  'STATUS',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.primary,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 36,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    'images/ui/secondary-background-2x.png'),
                                centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                                fit: BoxFit.fill,
                                filterQuality: FilterQuality.none,
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    'Dive Peck',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: colorScheme.primary),
                                  ),
                                ),
                                Container(
                                    width: 1,
                                    height: 24,
                                    color: colorScheme.primary),
                                SizedBox(width: 6),
                                SizedBox(
                                  width: 30,
                                  child: Text(
                                    '00:00',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: colorScheme.primary),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  width: 38,
                                  child: Text(
                                    '5-7',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: colorScheme.primary),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  width: 56,
                                  child: Text(
                                    'Physical',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: colorScheme.primary),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  width: 36,
                                  child: Text(
                                    '---',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: colorScheme.primary),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            height: 18,
                            width: double.infinity,
                            child: Text(
                              'STATUS EFFECTS',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.primary,
                                height: 1,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    'images/ui/secondary-background-2x.png'),
                                centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                                fit: BoxFit.fill,
                                filterQuality: FilterQuality.none,
                              ),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 40,
                                  width: double.infinity,
                                  child: Row(
                                    spacing: 6,
                                    children: [
                                      SizedBox(
                                          width: 54,
                                          child: Text('Poison',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: colorScheme.primary,
                                                  height: 1))),
                                      Container(
                                          width: 1,
                                          height: 24,
                                          color: colorScheme.primary),
                                      SizedBox(
                                          width: 30,
                                          child: Text(
                                            '00:00',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: colorScheme.primary,
                                                height: 1),
                                            textAlign: TextAlign.center,
                                          )),
                                      Text(
                                        '5 DMG every 30 min',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: colorScheme.primary,
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(width: 10),
            QvButton(
              onTap: () => QvEnemyInfoModal.showModal(context, enemyData),
              width: 80,
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/pixel-icons/open-book-red.png',
                    width: 30,
                    height: 30,
                    scale: .08,
                    filterQuality: FilterQuality.none,
                  ),
                  Text(
                    'Info',
                    style: TextStyle(
                      fontSize: 20,
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BasicAttackTargetSelectPanel extends StatelessWidget {
  final bool hasTarget;
  final int damage;
  final DamageType damageType;
  const BasicAttackTargetSelectPanel(
      {super.key,
      this.hasTarget = false,
      required this.damage,
      required this.damageType});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: hasTarget ? 140 : 120,
      width: MediaQuery.of(context).size.width * 0.6,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: QvPrimaryBorder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          children: [
            SizedBox(
              height: 26,
              child: Text(
                'Basic Attack',
                style: TextStyle(
                  fontSize: 22,
                  color: colorScheme.primary,
                  height: 1,
                ),
              ),
            ),
            Container(
              height: 1,
              width: MediaQuery.of(context).size.width * 0.3,
              color: colorScheme.primary,
            ),
            Container(
              height: 20,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                      width: 60,
                      child: Text(
                        'DMG',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.primary,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      )),
                  Expanded(
                      child: Text(
                    'TYPE',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.primary,
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                  )),
                ],
              ),
            ),
            Container(
              height: 40,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/ui/secondary-background-2x.png'),
                  centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.none,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      damage.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        color: colorScheme.primary,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      damageType.name,
                      style: TextStyle(
                        fontSize: 18,
                        color: colorScheme.primary,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            if (hasTarget)
              QvBlinking(
                  child: Text(
                'Tap Enemy again to Attack',
                style: TextStyle(
                  fontSize: 18,
                  color: colorScheme.primary,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ))
          ],
        ),
      ),
    );
  }
}

class SkillTargetSelectPanel extends StatelessWidget {
  final bool hasTarget;
  const SkillTargetSelectPanel({super.key, this.hasTarget = false});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: hasTarget ? 170 : 150,
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: QvPrimaryBorder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          children: [
            SizedBox(
              height: 26,
              child: Text(
                'Stormwave',
                style: TextStyle(
                  fontSize: 22,
                  color: colorScheme.primary,
                  height: 1,
                ),
              ),
            ),
            Container(
              height: 1,
              width: MediaQuery.of(context).size.width * 0.3,
              color: colorScheme.primary,
            ),
            Container(
              height: 20,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                      width: 60,
                      child: Text(
                        'DMG',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.primary,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      )),
                  SizedBox(
                      width: 60,
                      child: Text(
                        'TARGET',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.primary,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      )),
                  Expanded(
                      child: Text(
                    'TYPE',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.primary,
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                  )),
                ],
              ),
            ),
            Container(
              height: 40,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/ui/secondary-background-2x.png'),
                  centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.none,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      '20',
                      style: TextStyle(
                        fontSize: 18,
                        color: colorScheme.primary,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      'All',
                      style: TextStyle(
                        fontSize: 18,
                        color: colorScheme.primary,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Physical',
                      style: TextStyle(
                        fontSize: 18,
                        color: colorScheme.primary,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
              child: Text(
                'Sends out a wave of water that deals damage to all enemies',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.primary,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (hasTarget)
              QvBlinking(
                  child: Text(
                'Tap Enemy again to Attack',
                style: TextStyle(
                  fontSize: 18,
                  color: colorScheme.primary,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ))
          ],
        ),
      ),
    );
  }
}
