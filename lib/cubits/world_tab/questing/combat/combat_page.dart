import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/home/player_state.dart';
import 'package:questvale/cubits/world_tab/questing/combat/combat_cubit.dart';
import 'package:questvale/cubits/world_tab/questing/combat/combat_state.dart';
import 'package:questvale/cubits/world_tab/questing/quest_encounter/quest_encounter_cubit.dart';
import 'package:questvale/cubits/world_tab/questing/quest_encounter/quest_flee_confirmation_modal.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/widgets/qv_animated_transition.dart';
import 'package:questvale/widgets/qv_blinking.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_card_border.dart';
import 'package:questvale/widgets/qv_metal_corner_border.dart';
import 'package:questvale/widgets/qv_skill_button.dart';
import 'package:sqflite/sqflite.dart';

class CombatPage extends StatelessWidget {
  const CombatPage({super.key, required this.encounterId});
  final String encounterId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CombatCubit>(
        create: (context) =>
            CombatCubit(encounterId: encounterId, db: context.read<Database>()),
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
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<CombatCubit, CombatState>(
        builder: (context, combatState) {
      return BlocListener<CombatCubit, CombatState>(
        listenWhen: (prev, next) =>
            prev.status != CombatStatus.complete &&
            next.status == CombatStatus.complete,
        listener: (context, combatState) async {
          if (combatState.status == CombatStatus.complete) {
            await context.read<QuestEncounterCubit>().completeEncounter();
          }
        },
        child: BlocBuilder<PlayerCubit, PlayerState>(
            builder: (context, playerState) {
          final character = playerState.character;
          final playerSkills = playerState.playerSkills;
          if (character == null || playerSkills == null) {
            return const SizedBox.shrink();
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(height: 10),
              SizedBox(
                height: 138,
                child: Row(
                  children: [
                    Container(
                      width: 84,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          QvButton(
                            width: 64,
                            height: 64,
                            buttonColor: ButtonColor.silver,
                            padding: EdgeInsets.only(bottom: 10),
                            onTap: () {
                              if (combatState.status == CombatStatus.idle) {
                                QuestFleeConfirmationModal.showModal(
                                    context,
                                    () => context
                                        .read<QuestEncounterCubit>()
                                        .fleeQuest());
                              }
                            },
                            child: Center(
                              child: Image.asset(
                                'images/pixel-icons/running-man.png',
                                filterQuality: FilterQuality.none,
                                width: 40,
                                height: 40,
                                scale: .08,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          QvButton(
                            width: 64,
                            height: 64,
                            buttonColor: ButtonColor.rare,
                            padding: EdgeInsets.only(bottom: 0),
                            child: Center(
                              child: Image.asset(
                                'images/pixel-icons/potion-star.png',
                                filterQuality: FilterQuality.none,
                                width: 40,
                                height: 40,
                                scale: .08,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: Container()),
                    Container(
                      width: 84,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.topCenter,
                      child: QvButton(
                        width: 64,
                        height: 64,
                        buttonColor: ButtonColor.surface,
                        padding: EdgeInsets.only(bottom: 0),
                        child: Center(
                          child: Image.asset(
                            'images/pixel-icons/bag.png',
                            filterQuality: FilterQuality.none,
                            width: 40,
                            height: 40,
                            scale: .08,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              BattleFieldDisplay(),
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
                        ),
                    ],
                  )),
              SizedBox(
                height: 80,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: ResourceBar(
                        color: HEALTH_COLOR,
                        maxValue: character.maxHealth,
                        currentValue: character.currentHealth,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'images/ui/buttons/primary-button-no-bottom-2x.png'),
                          centerSlice: STANDARD_BORDER_SLICE,
                          fit: BoxFit.fill,
                        ),
                      ),
                      width: 80,
                      height: combatState.status == CombatStatus.targetingSkill
                          ? 80
                          : 50,
                      padding: const EdgeInsets.symmetric(horizontal: 2),
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
                                character.actionPoints.toString(),
                                style: TextStyle(
                                  fontSize: 36,
                                  color: colorScheme.secondary,
                                  height: 1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (combatState.status ==
                                CombatStatus.targetingSkill)
                              SizedBox(
                                height: 30,
                                child: Text(
                                  '(-${combatState.targetingSkill?.data.apCost ?? 0})',
                                  style: TextStyle(
                                    fontSize: 30,
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
                    Expanded(
                      child: ResourceBar(
                        color: MANA_COLOR,
                        maxValue: character.maxMana,
                        currentValue: character.currentMana,
                        alignment: Alignment.centerRight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      );
    });
  }
}

class ResourceBar extends StatelessWidget {
  const ResourceBar({
    super.key,
    required this.color,
    required this.maxValue,
    required this.currentValue,
    required this.alignment,
  });
  final Color color;
  final int maxValue;
  final int currentValue;
  final Alignment alignment;
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 40,
      child: Column(
        children: [
          Container(height: 2, color: colorScheme.secondary),
          Stack(
            alignment: alignment,
            children: [
              Container(height: 38, color: Colors.white.withValues(alpha: 0.3)),
              FractionallySizedBox(
                widthFactor: currentValue / maxValue,
                child: Container(color: color, height: 38),
              ),
              Center(
                child: Text(
                  '$currentValue / $maxValue',
                  style: TextStyle(
                      fontSize: 22, color: Colors.grey[100], height: 1),
                ),
              ),
            ],
          ),
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
    return QvSkillButton(
      skillIconPath: skill.data.iconPath,
      onTap: onTap,
      width: 65,
      height: 65,
      skillButtonColor: skill.data.buttonColor,
      darkened: darkened,
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
                  padding: const EdgeInsets.only(
                      left: 30, right: 30, top: 40, bottom: 40),
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
      child: QvMetalCornerBorder(
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
                            style: TextStyle(
                              fontSize: 24,
                              color: colorScheme.secondary,
                            ),
                          )),
                        ),
                        Container(
                          height: 30,
                          color: colorScheme.secondary,
                          padding: EdgeInsets.all(2),
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: Stack(
                            children: [
                              FractionallySizedBox(
                                widthFactor:
                                    enemy.currentHealth / enemyData.health,
                                child: Container(
                                  height: double.infinity,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                    image: AssetImage(
                                        'images/ui/health-border.png'),
                                    centerSlice: HEALTH_BORDER_SLICE,
                                    fit: BoxFit.fill,
                                    filterQuality: FilterQuality.none,
                                  )),
                                ),
                              ),
                              Center(
                                child: Text(
                                  '${enemy.currentHealth} / ${enemyData.health}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[100],
                                    height: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    EnemyNextAttackSlice(),
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
            QvButton(
              width: double.infinity,
              height: 36,
              buttonColor: ButtonColor.primary,
              onTap: () => context.read<CombatCubit>().setIdle(),
              child: Center(
                  child: Text(
                'Close',
                style: TextStyle(
                  fontSize: 24,
                  color: colorScheme.secondary,
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class EnemyNextAttackSlice extends StatelessWidget {
  const EnemyNextAttackSlice({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              'Next Attack',
              style: TextStyle(
                  fontSize: 16, color: colorScheme.primary, height: 1),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/ui/secondary-background-2x.png'),
              centerSlice: STANDARD_BORDER_SLICE,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            ),
          ),
          child: Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(
                  child: Text('1:12',
                      style: TextStyle(
                          fontSize: 20, color: Colors.grey[100], height: 1),
                      textAlign: TextAlign.center)),
              Container(width: 2, height: 20, color: colorScheme.primary),
              SizedBox(width: 20),
              Expanded(
                  flex: 3,
                  child: Text(
                    'Slam',
                    style: TextStyle(
                        fontSize: 20, color: colorScheme.primary, height: 1),
                  )),
              Expanded(
                  child: Text('8-12',
                      style: TextStyle(
                          fontSize: 20, color: colorScheme.primary, height: 1),
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
    return Column(
      children: [
        Text('Status Effects'),
        Container(
          height: 40,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/ui/secondary-background-2x.png'),
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
      child: QvMetalCornerBorder(
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
                style: TextStyle(
                  fontSize: 24,
                  color: colorScheme.secondary,
                ),
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
      child: QvMetalCornerBorder(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Text(skill.data.name),
            Text(skill.description),
            Text(
                'Damage: ${(skill.data.primaryBaseValue! * playerCombatStats.physicalAttackPower).toStringAsFixed(0)}'),
            Text('Damage Type: ${skill.data.damageType?.name}'),
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
                style: TextStyle(fontSize: 24, color: colorScheme.secondary),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
