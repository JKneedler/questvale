import 'package:flutter/material.dart';
import 'package:questvale/data/models/enemy_attack_data.dart';
import 'package:questvale/data/models/enemy_data.dart';
import 'package:questvale/data/models/enemy_drop_data.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/widgets/qv_gray_filter.dart';
import 'package:questvale/widgets/qv_card_border.dart';

class QvEnemyInfoModal extends StatelessWidget {
  final EnemyData enemyData;
  const QvEnemyInfoModal({super.key, required this.enemyData});

  static Future<void> showModal(BuildContext context, EnemyData enemyData) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return QvEnemyInfoModal(
          enemyData: enemyData,
        );
      },
    );
  }

  double _calculateMaxElementsHeight() {
    double maxHeight = 24;
    if (enemyData.immunities.isNotEmpty) {
      double immunitiesHeight = enemyData.immunities.length * 18;
      if (immunitiesHeight > maxHeight) {
        maxHeight = immunitiesHeight;
      }
    }
    if (enemyData.resistances.isNotEmpty) {
      double resistancesHeight = enemyData.resistances.length * 18;
      if (resistancesHeight > maxHeight) {
        maxHeight = resistancesHeight;
      }
    }
    if (enemyData.weaknesses.isNotEmpty) {
      double weaknessesHeight = enemyData.weaknesses.length * 18;
      if (weaknessesHeight > maxHeight) {
        maxHeight = weaknessesHeight;
      }
    }
    return maxHeight;
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: SizedBox(
        width: 360,
        height: 560,
        child: Stack(
          children: [
            Center(
              child: FractionallySizedBox(
                widthFactor: .95,
                heightFactor: .95,
                child: Container(
                  color: colorScheme.surface,
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    spacing: 8,
                    children: [
                      Row(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.only(left: 8),
                              height: 50,
                              child: Container(
                                width: 260,
                                padding: const EdgeInsets.only(left: 16),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'images/ui/buttons/${enemyData.rarity.name.toLowerCase()}-button-2x.png'),
                                    centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                                    fit: BoxFit.fill,
                                    filterQuality: FilterQuality.none,
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    enemyData.name,
                                    style: TextStyle(
                                      fontSize: 32,
                                      color: colorScheme.secondary,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(child: SizedBox.shrink()),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.only(right: 12),
                              height: 50,
                              width: 40,
                              child: Text(
                                'x',
                                style: TextStyle(
                                  fontSize: 36,
                                  color: colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        height: 120,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            QvCardBorder(
                              rarity: enemyData.rarity,
                              width: 100,
                              height: 140,
                              bgColor: colorScheme.secondary,
                              child: Image.asset(
                                'images/enemies/${enemyData.id.toLowerCase()}.png',
                                filterQuality: FilterQuality.none,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.only(left: 12, right: 12),
                                height: 140,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    EnemyInfoLine(
                                        label: 'Type',
                                        value: enemyData.enemyType.name
                                            .toUpperCase()),
                                    Center(
                                      child: Container(
                                        height: 1.5,
                                        width: 175,
                                        color: colorScheme.secondary,
                                      ),
                                    ),
                                    EnemyInfoLine(
                                        label: 'Rarity',
                                        value: enemyData.rarity.name
                                            .toUpperCase()),
                                    Center(
                                      child: Container(
                                        height: 1.5,
                                        width: 175,
                                        color: colorScheme.secondary,
                                      ),
                                    ),
                                    EnemyInfoLine(
                                        label: 'Health',
                                        value: enemyData.health.toString()),
                                    Center(
                                      child: Container(
                                        height: 1.5,
                                        width: 175,
                                        color: colorScheme.secondary,
                                      ),
                                    ),
                                    EnemyInfoLine(
                                        label: 'Exp.',
                                        value: enemyData.experience.toString()),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        height: 325,
                        width: 320,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: 320,
                                height: 26 + // Title height
                                    10 + // Container padding
                                    _calculateMaxElementsHeight(),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  spacing: 8,
                                  children: [
                                    ElementsView(
                                      title: 'Immunities',
                                      elements: enemyData.immunities,
                                      height:
                                          10 + _calculateMaxElementsHeight(),
                                    ),
                                    Container(
                                      width: 1.5,
                                      height: 26 +
                                          10 +
                                          _calculateMaxElementsHeight() * .75,
                                      color: colorScheme.secondary,
                                    ),
                                    ElementsView(
                                      title: 'Resistances',
                                      elements: enemyData.resistances,
                                      height:
                                          10 + _calculateMaxElementsHeight(),
                                    ),
                                    Container(
                                      width: 1.5,
                                      height: 26 +
                                          10 +
                                          _calculateMaxElementsHeight() * .75,
                                      color: colorScheme.secondary,
                                    ),
                                    ElementsView(
                                      title: 'Weaknesses',
                                      elements: enemyData.weaknesses,
                                      height:
                                          10 + _calculateMaxElementsHeight(),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 12, right: 12),
                                height: 30,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Attacks',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: colorScheme.onSecondary,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    SizedBox(
                                        width: 50,
                                        child: Text(
                                          'DMG',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: colorScheme.onSecondary),
                                          textAlign: TextAlign.center,
                                        )),
                                    SizedBox(
                                        width: 50,
                                        child: Text(
                                          'SPD',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: colorScheme.onSecondary),
                                          textAlign: TextAlign.center,
                                        )),
                                    SizedBox(
                                        width: 50,
                                        child: Text(
                                          'TYPE',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: colorScheme.onSecondary),
                                          textAlign: TextAlign.center,
                                        )),
                                  ],
                                ),
                              ),
                              Container(
                                height: enemyData.attacks.length * 53,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                      'images/ui/secondary-background-2x.png',
                                    ),
                                    centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: enemyData.attacks.length,
                                  itemBuilder: (context, index) {
                                    return EnemyAttackView(
                                      attack: enemyData.attacks[index],
                                      includeSeparator:
                                          index != enemyData.attacks.length - 1,
                                    );
                                  },
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 12, right: 12),
                                height: 30,
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      'Drops',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: colorScheme.onSecondary),
                                      textAlign: TextAlign.start,
                                    )),
                                    SizedBox(
                                        width: 80,
                                        child: Text(
                                          'USES',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: colorScheme.onSecondary),
                                          textAlign: TextAlign.center,
                                        )),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 320,
                                height: 82.0 * enemyData.drops.length,
                                child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: enemyData.drops.length,
                                  itemBuilder: (context, index) {
                                    return EnemyDropView(
                                        drop: enemyData.drops[index]);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EnemyInfoLine extends StatelessWidget {
  const EnemyInfoLine({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 20,
                color: colorScheme.onSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              color: colorScheme.onSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class ElementsView extends StatelessWidget {
  final String title;
  final List<DamageType> elements;
  final double height;

  const ElementsView(
      {super.key,
      required this.title,
      required this.elements,
      required this.height});

  String _capitalize(String string) {
    return string.substring(0, 1).toUpperCase() + string.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, color: colorScheme.onSecondary),
            textAlign: TextAlign.center,
          ),
          Container(
            height: height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/ui/secondary-background-2x.png'),
                centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                fit: BoxFit.fill,
                filterQuality: FilterQuality.none,
              ),
            ),
            padding:
                const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 6),
            child: elements.isNotEmpty
                ? SizedBox(
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: elements.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          height: 18,
                          child: Text(
                            _capitalize(elements[index].name),
                            style: TextStyle(
                              fontSize: 16,
                              color: elements[index].color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  )
                : SizedBox(
                    height: 18,
                    child: Text(
                      'None',
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class EnemyAttackView extends StatelessWidget {
  final EnemyAttackData attack;
  final bool includeSeparator;
  const EnemyAttackView(
      {super.key, required this.attack, this.includeSeparator = true});

  String _capitalize(String string) {
    return string.substring(0, 1).toUpperCase() + string.substring(1);
  }

  String _getAttackCooldown(double cooldown) {
    int hours = cooldown.floor();
    int minutes = ((cooldown % 1) * 60).round();
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 12, right: 12),
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Text(
                  attack.name,
                  style: TextStyle(
                    fontSize: 20,
                    color: colorScheme.onSecondary,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              AttackAttributeSlice(value: attack.damage.toString()),
              AttackAttributeSlice(value: _getAttackCooldown(attack.cooldown)),
              AttackAttributeSlice(
                  value: _capitalize(attack.damageType.name),
                  color: attack.damageType.color),
            ],
          ),
        ),
        if (includeSeparator)
          Container(
            width: 240,
            height: 1.5,
            color: colorScheme.surface,
          ),
      ],
    );
  }
}

class AttackAttributeSlice extends StatelessWidget {
  final String value;
  final Color? color;
  const AttackAttributeSlice({super.key, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 50,
      child: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          color: color ?? colorScheme.onSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class EnemyDropView extends StatelessWidget {
  final EnemyDropData drop;
  const EnemyDropView({super.key, required this.drop});

  String _capitalize(String string) {
    return string.substring(0, 1).toUpperCase() + string.substring(1);
  }

  String _getDropString() {
    return drop.itemQuantityMin == drop.itemQuantityMax
        ? '${(drop.dropChance * 100).toStringAsFixed(0)}%  :  ${drop.itemQuantityMin.toString()}'
        : '${(drop.dropChance * 100).toStringAsFixed(0)}%  :  ${drop.itemQuantityMin.toString()}-${drop.itemQuantityMax.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    // TODO: Add discovered logic
    bool discovered = true;
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: QvCardBorder(
        rarity: drop.rarity,
        height: 80,
        widthFactor: .96,
        bgColor: colorScheme.secondary,
        padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 12),
        child: Row(
          spacing: 8,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/ui/surface-background-2x.png'),
                    centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.none,
                  ),
                ),
                child: discovered
                    ? Image.asset(
                        'images/enemies/drops/${drop.id.toLowerCase()}.png',
                        filterQuality: FilterQuality.none,
                      )
                    : QVGrayFilter(
                        child: Image.asset(
                          'images/pixel-icons/question-mark.png',
                          filterQuality: FilterQuality.none,
                        ),
                      ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 16,
                    child: Text(
                      discovered ? drop.itemName : '',
                      style: TextStyle(
                          fontSize: 20,
                          color: colorScheme.onSecondary,
                          height: .8),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                    child: Text(
                      discovered ? _getDropString() : '',
                      style: TextStyle(
                          fontSize: 16, color: colorScheme.onSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 80,
              child: Text(
                discovered
                    ? drop.useCases.map((e) => _capitalize(e.name)).join('\n')
                    : '',
                style: TextStyle(
                    fontSize: 12, color: colorScheme.onSecondary, height: 1.0),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
