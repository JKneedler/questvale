import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/select_quest/select_quest_cubit.dart';
import 'package:questvale/widgets/qv_app_bar.dart';

class SelectQuestPage extends StatelessWidget {
  const SelectQuestPage({super.key});

  final List<QuestLocaleData> questLocales = const [
    QuestLocaleData(
        name: 'Fieldlands',
        backgroundImage: 'images/backgrounds/fieldlands.png',
        areaLevel: 1,
        isUnlocked: true,
        enemies: [
          ZoneEnemyData(
              name: 'Slime',
              iconLocation: 'images/enemies/slime.png',
              rarity: EnemyRarity.common,
              isDiscovered: true),
          ZoneEnemyData(
              name: 'Slime',
              iconLocation: 'images/enemies/slime.png',
              rarity: EnemyRarity.uncommon,
              isDiscovered: true),
          ZoneEnemyData(
              name: 'Slime',
              iconLocation: 'images/enemies/slime.png',
              rarity: EnemyRarity.rare,
              isDiscovered: true),
          ZoneEnemyData(
              name: 'Slime',
              iconLocation: 'images/enemies/slime.png',
              rarity: EnemyRarity.epic,
              isDiscovered: true),
          ZoneEnemyData(
              name: 'Slime',
              iconLocation: 'images/enemies/slime.png',
              rarity: EnemyRarity.legendary,
              isDiscovered: true),
          ZoneEnemyData(
              name: 'Slime',
              iconLocation: 'images/enemies/slime.png',
              rarity: EnemyRarity.mythic,
              isDiscovered: true),
          ZoneEnemyData(
              name: 'Slime',
              iconLocation: 'images/enemies/slime.png',
              rarity: EnemyRarity.mythic,
              isDiscovered: false),
        ]),
    QuestLocaleData(
        name: 'Verdant Hollow',
        backgroundImage: 'images/backgrounds/verdant-hollow.png',
        areaLevel: 10,
        isUnlocked: true),
    QuestLocaleData(
        name: 'Ashfen Marsh',
        backgroundImage: 'images/backgrounds/ashfen-marsh.png',
        areaLevel: 20,
        isUnlocked: true),
    QuestLocaleData(
        name: 'Cragspire Foothills',
        backgroundImage: 'images/backgrounds/cragspire-foothills.png',
        areaLevel: 30,
        isUnlocked: true),
    QuestLocaleData(
        name: 'Ember Caverns',
        backgroundImage: 'images/backgrounds/ember-caverns.png',
        areaLevel: 40,
        isUnlocked: true),
    QuestLocaleData(
        name: 'Howling Steppe',
        backgroundImage: 'images/backgrounds/howling-steppe.png',
        areaLevel: 50,
        isUnlocked: true),
    QuestLocaleData(
        name: 'Shattered Coast',
        backgroundImage: 'images/backgrounds/shattered-coast.png',
        areaLevel: 60,
        isUnlocked: true),
    QuestLocaleData(
        name: 'Obsidian Depths',
        backgroundImage: 'images/backgrounds/obsidian-depths.png',
        areaLevel: 70,
        isUnlocked: true),
    QuestLocaleData(
        name: 'Frostbound Expanse',
        backgroundImage: 'images/backgrounds/frostbound-expanse.png',
        areaLevel: 80,
        isUnlocked: true),
    QuestLocaleData(
        name: 'Tomb of Whispers',
        backgroundImage: 'images/backgrounds/tomb-of-whispers.png',
        areaLevel: 90,
        isUnlocked: true),
    QuestLocaleData(
        name: 'Eclipsed Citadel',
        backgroundImage: 'images/backgrounds/eclipsed-citadel.png',
        areaLevel: 100,
        isUnlocked: true),
    QuestLocaleData(
        name: 'Heart of the Abyss',
        backgroundImage: 'images/backgrounds/heart-of-the-abyss.png',
        areaLevel: 110,
        isUnlocked: true),
  ];

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          QVAppBar(title: 'Select a Location', includeBackButton: true),
          Expanded(
            child: Container(
              color: colorScheme.surface,
              child: BlocProvider(
                create: (context) => SelectQuestCubit(),
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 10,
                    bottom: 10,
                  ),
                  itemCount: questLocales.length,
                  itemBuilder: (context, index) {
                    final isOpen =
                        context.watch<SelectQuestCubit>().state == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SelectQuestZoneCard(
                        questLocale: questLocales[index],
                        isOpen: isOpen,
                        onTap: () =>
                            context.read<SelectQuestCubit>().toggle(index),
                      ),
                    );
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class QuestLocaleData {
  final String name;
  final String backgroundImage;
  final int areaLevel;
  final bool isUnlocked;
  final List<ZoneEnemyData> enemies;

  const QuestLocaleData({
    required this.name,
    required this.backgroundImage,
    required this.areaLevel,
    required this.isUnlocked,
    this.enemies = const [],
  });
}

enum EnemyRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
  mythic,
}

class ZoneEnemyData {
  final String name;
  final String iconLocation;
  final EnemyRarity rarity;
  final bool isDiscovered;

  const ZoneEnemyData({
    required this.name,
    required this.iconLocation,
    required this.rarity,
    required this.isDiscovered,
  });
}

class SelectQuestZoneCard extends StatelessWidget {
  const SelectQuestZoneCard(
      {super.key,
      required this.questLocale,
      required this.isOpen,
      required this.onTap});
  final QuestLocaleData questLocale;
  final bool isOpen;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      height: isOpen ? 300 : 120,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onTap,
                child: Center(
                  child: FractionallySizedBox(
                    widthFactor: .94,
                    child: Container(
                        margin: const EdgeInsets.only(top: 6),
                        height: 105,
                        padding: const EdgeInsets.only(
                          left: 40,
                          right: 40,
                          top: 20,
                          bottom: 20,
                        ),
                        decoration: BoxDecoration(
                          image: questLocale.backgroundImage.isNotEmpty
                              ? DecorationImage(
                                  image:
                                      AssetImage(questLocale.backgroundImage),
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.none,
                                )
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 30,
                                    child: Text(questLocale.name,
                                        style: TextStyle(
                                          fontSize: 28,
                                          color: colorScheme.secondary,
                                        )),
                                  ),
                                  Text('Level ${questLocale.areaLevel}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: colorScheme.secondary,
                                      )),
                                ],
                              ),
                            ),
                            Center(
                              child: Text(
                                '>',
                                style: TextStyle(
                                  fontSize: 28,
                                  color: colorScheme.secondary,
                                ),
                              ),
                            ),
                          ],
                        )),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                height: isOpen ? 180 : 0,
                child: FractionallySizedBox(
                  widthFactor: .94,
                  child: Container(
                    color: colorScheme.secondary,
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        children: [
                          isOpen
                              ? SizedBox(
                                  height: 80,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 30,
                                        child: Center(
                                            child: Text(
                                          '<',
                                          style: TextStyle(
                                              fontSize: 24,
                                              color: colorScheme.onSecondary),
                                        )),
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: questLocale.enemies.length,
                                          itemBuilder: (context, index) {
                                            return ZoneEnemyCard(
                                              enemy: questLocale.enemies[index],
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: 30,
                                        child: Center(
                                            child: Text(
                                          '>',
                                          style: TextStyle(
                                              fontSize: 24,
                                              color: colorScheme.onSecondary),
                                        )),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(height: 80),
                          SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: GestureDetector(
                              onTap: () => print('embark'),
                              child: Container(
                                width: double.infinity,
                                height: 40,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                                    image: AssetImage(
                                      'images/ui/buttons/white-button-filled-2x.png',
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Embark',
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.only(
                  left: 40,
                  right: 40,
                  top: 30,
                  bottom: 30,
                ),
                foregroundDecoration: BoxDecoration(
                  image: DecorationImage(
                    image:
                        AssetImage('images/ui/borders/primary-border-2x.png'),
                    centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.none,
                  ),
                ),
                child: Column(
                  children: [],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ZoneEnemyCard extends StatelessWidget {
  const ZoneEnemyCard({
    super.key,
    required this.enemy,
  });

  final ZoneEnemyData enemy;

  Future<void> _enemyInfoDialog(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: SizedBox(
            width: 360,
            height: 500,
            child: Stack(
              children: [
                Center(
                  child: FractionallySizedBox(
                    widthFactor: .94,
                    heightFactor: .94,
                    child: Container(
                      color: colorScheme.surface,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 100,
                                height: 140,
                                child: Stack(
                                  children: [
                                    Center(
                                      child: FractionallySizedBox(
                                        widthFactor: 94,
                                        heightFactor: .94,
                                        child: Container(
                                          color: colorScheme.secondary,
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Container(
                                        foregroundDecoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'images/ui/borders/${enemy.rarity.name.toLowerCase()}-border-mini-2x.png'),
                                            centerSlice:
                                                Rect.fromLTWH(16, 16, 32, 32),
                                            filterQuality: FilterQuality.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                            'images/ui/borders/primary-metal-edge-border-2x.png'),
                        centerSlice: Rect.fromLTWH(28, 28, 8, 8),
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.none,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(enemy.name),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _enemyInfoDialog(context),
      child: ColorFiltered(
        colorFilter: enemy.isDiscovered
            ? const ColorFilter.mode(Colors.transparent, BlendMode.color)
            : const ColorFilter.matrix(<double>[
                // R         G         B         A  Bias
                0.2126, 0.7152, 0.0722, 0, 0, // R'
                0.2126, 0.7152, 0.0722, 0, 0, // G'
                0.2126, 0.7152, 0.0722, 0, 0, // B'
                0, 0, 0, 1, 0, // A'
              ]),
        child: Container(
          margin: const EdgeInsets.only(right: 6),
          height: 80,
          width: 70,
          child: Stack(
            children: [
              Center(
                child: FractionallySizedBox(
                  widthFactor: .9,
                  heightFactor: .9,
                  child: Container(
                    color: colorScheme.surface,
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'images/ui/borders/${enemy.rarity.name.toLowerCase()}-border-mini-2x.png'),
                      centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.none,
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    enemy.isDiscovered
                        ? enemy.iconLocation
                        : 'images/pixel-icons/question-mark.png',
                    filterQuality: FilterQuality.none,
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
