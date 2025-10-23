import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/character_data_cubit.dart';
import 'package:questvale/cubits/home/character_data_state.dart';
import 'package:questvale/helpers/constants.dart';

class QVNavBar extends StatelessWidget {
  const QVNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.showCharacterResources = true,
    this.showCharacterAP = true,
  });

  final List<QVNavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool showCharacterResources;
  final bool showCharacterAP;

  AssetImage getImage(int index) {
    if (index == currentIndex) {
      if (index == 0) {
        return AssetImage('images/ui/borders/primary-nav-selected-left-2x.png');
      } else if (index == 4) {
        return AssetImage(
            'images/ui/borders/primary-nav-selected-right-2x.png');
      } else {
        return AssetImage(
            'images/ui/borders/primary-nav-selected-wider-2x.png');
      }
    } else if (index == currentIndex - 1) {
      return AssetImage('images/ui/borders/primary-nav-top-left-2x.png');
    } else if (index == currentIndex + 1) {
      return AssetImage('images/ui/borders/primary-nav-top-right-2x.png');
    } else {
      return AssetImage('images/ui/borders/primary-nav-top-2x.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Material(
      elevation: 10,
      color: colorScheme.primary,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCharacterResources)
              Container(height: 2, color: colorScheme.secondary),
            if (showCharacterResources)
              BlocBuilder<CharacterDataCubit, CharacterDataState>(
                  builder: (context, characterDataState) {
                return Container(
                  height: 26,
                  color: colorScheme.secondary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CharacterResourceBar(
                        maxValue: characterDataState.character?.maxHealth ?? 0,
                        currentValue:
                            characterDataState.character?.currentHealth ?? 0,
                        color: HEALTH_COLOR,
                        startAlignment: Alignment.centerLeft,
                        showCharacterAP: showCharacterAP,
                      ),
                      Expanded(
                        child: showCharacterAP
                            ? Container(
                                alignment: Alignment.center,
                                color: Colors.grey[200],
                                child: Text(
                                  '${characterDataState.character?.attacksRemaining ?? 0}',
                                  style: TextStyle(
                                    color: colorScheme.secondary,
                                    fontSize: 30,
                                    height: .9,
                                  ),
                                ),
                              )
                            : Container(color: Colors.grey[200]),
                      ),
                      CharacterResourceBar(
                        maxValue: characterDataState.character?.maxMana ?? 0,
                        currentValue:
                            characterDataState.character?.currentMana ?? 0,
                        color: MANA_COLOR,
                        startAlignment: Alignment.centerRight,
                        showCharacterAP: showCharacterAP,
                      ),
                      // CharacterResourceBar(
                      //     maxValue: characterDataState.character?.maxMana ?? 0,
                      //     currentValue:
                      //         characterDataState.character?.currentMana ?? 0,
                      //     color: RAGE_COLOR,
                      //     startAlignment: Alignment.centerRight),
                      // CharacterResourceBar(
                      //     maxValue: characterDataState.character?.maxMana ?? 0,
                      //     currentValue:
                      //         characterDataState.character?.currentMana ?? 0,
                      //     color: FOCUS_COLOR,
                      //     startAlignment: Alignment.centerRight),
                    ],
                  ),
                );
              }),
            SizedBox(
              width: MediaQuery.of(context).size.width + 20,
              height: 48 + bottomPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: List.generate(items.length, (i) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(i),
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          image: DecorationImage(
                            image: getImage(i),
                            centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                            fit: BoxFit.fill,
                            filterQuality: FilterQuality.none,
                          ),
                        ),
                        child: Column(
                          spacing: 4,
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 35,
                              height: 35,
                              child: items[i].icon,
                            ),
                            Text(
                              items[i].label,
                              style: TextStyle(
                                color: currentIndex == i
                                    ? colorScheme.onSurface
                                    : colorScheme.onPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QVNavBarItem {
  const QVNavBarItem({
    required this.icon,
    required this.label,
    this.activeColor = const Color(0xFF9B87F5),
    this.inactiveColor = const Color(0xFF9AA0A6),
  });

  final Widget icon;
  final String label;
  final Color activeColor;
  final Color inactiveColor;
}

class CharacterResourceBar extends StatelessWidget {
  const CharacterResourceBar({
    super.key,
    required this.maxValue,
    required this.currentValue,
    required this.color,
    required this.startAlignment,
    required this.showCharacterAP,
  });

  final int maxValue;
  final int currentValue;
  final Color color;
  final Alignment startAlignment;
  final bool showCharacterAP;

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.of(context).size.width - (showCharacterAP ? 60 : 1.5);
    return SizedBox(
        width: width / 2,
        height: double.infinity,
        child: Stack(
          alignment: startAlignment,
          children: [
            Container(
              color: color,
              height: double.infinity,
              width: width / 2 * (currentValue / maxValue),
            ),
            Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text(
                '${currentValue.toStringAsFixed(0)} / ${maxValue.toStringAsFixed(0)}',
                style: TextStyle(color: Colors.white, fontSize: 24, height: 1),
              ),
            ),
          ],
        ));
  }
}
