import 'package:flutter/material.dart';
import 'package:questvale/data/models/encounter.dart';
import 'package:questvale/data/models/enemy.dart';
import 'package:questvale/data/models/quest_zone.dart';
import 'package:questvale/widgets/qv_silver_button.dart';

class CombatEncounterView extends StatelessWidget {
  final Encounter encounter;
  final QuestZone zone;
  const CombatEncounterView(
      {super.key, required this.encounter, required this.zone});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Expanded(
          child: Container(
            height: 200,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var enemy in encounter.enemies)
                  EnemyView(enemy: enemy, zone: zone),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              QvSilverButton(
                width: 64,
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('20'),
              ),
              QvSilverButton(
                width: 64,
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('20'),
              ),
              QvSilverButton(
                width: 64,
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('20'),
              ),
              QvSilverButton(
                width: 64,
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('20'),
              ),
              QvSilverButton(
                width: 64,
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('20'),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                QvSilverButton(
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Text(
                      'Bag',
                      style: TextStyle(
                        fontSize: 30,
                        color: colorScheme.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                QvSilverButton(
                  width: 80,
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Center(
                    child: Text(
                      '20',
                      style: TextStyle(
                        fontSize: 36,
                        color: colorScheme.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                QvSilverButton(
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Text(
                      'Flee',
                      style: TextStyle(
                        fontSize: 30,
                        color: colorScheme.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class EnemyView extends StatelessWidget {
  final Enemy enemy;
  final QuestZone zone;

  const EnemyView({super.key, required this.enemy, required this.zone});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      height: 200,
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
                        'images/backgrounds/${zone.id.toLowerCase()}.png'),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.none,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    QvSilverButton(
                      width: 100,
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Center(
                        child: Text(
                          enemy.enemyData.name,
                          style: TextStyle(
                            fontSize: 18,
                            color: colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Image.asset(
                        'images/enemies/${enemy.enemyData.id}.png',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
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
                      'images/ui/borders/${enemy.enemyData.rarity.name.toLowerCase()}-border-mini-2x.png'),
                  centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
