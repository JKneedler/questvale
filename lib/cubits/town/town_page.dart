import 'package:flutter/material.dart';
import 'package:questvale/cubits/select_quest/select_quest_page.dart';
import 'package:questvale/widgets/qv_app_bar.dart';
import 'package:questvale/widgets/qv_white_card.dart';

class TownPage extends StatelessWidget {
  const TownPage({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    const padding = 16.0;

    return Scaffold(
      body: Column(
        children: [
          QVAppBar(title: 'Town'),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: padding, bottom: padding),
              decoration: BoxDecoration(
                color: colorScheme.surface,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: padding,
                children: [
                  SizedBox(
                    height: 150.0,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: padding, right: padding),
                      child: QVWhiteCard(
                        onTap: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SelectQuestPage()))
                        },
                        padding: EdgeInsets.only(
                            left: 52, right: 52, top: 30, bottom: 30),
                        child: Row(
                          spacing: 32,
                          children: [
                            Image.asset(
                              'images/pixel-icons/portal.png',
                              filterQuality: FilterQuality.none,
                            ),
                            Text(
                              'Get a Quest',
                              style: TextStyle(
                                color: colorScheme.onSecondary,
                                fontSize: 28,
                              ),
                            ),
                            Text(
                              '>',
                              style: TextStyle(
                                color: colorScheme.onSecondary,
                                fontSize: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: padding, right: padding),
                      child: Row(
                        spacing: padding,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TownLocationCard(
                            title: 'Shop',
                            image: 'images/pixel-icons/all-coins-stack.png',
                            onTap: () => {},
                            requiredLevel: 0,
                            isUnlocked: true,
                          ),
                          TownLocationCard(
                            title: 'Blacksmith',
                            image: 'images/pixel-icons/anvil-hammer-star.png',
                            onTap: () => {},
                            requiredLevel: 5,
                            isUnlocked: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: padding, right: padding),
                      child: Row(
                        spacing: padding,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TownLocationCard(
                            title: 'Jeweler',
                            image: 'images/pixel-icons/jewel-star.png',
                            onTap: () => {},
                            requiredLevel: 10,
                            isUnlocked: false,
                          ),
                          TownLocationCard(
                            title: 'Alchemist',
                            image: 'images/pixel-icons/potion-star.png',
                            onTap: () => {},
                            requiredLevel: 15,
                            isUnlocked: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TownLocationCard extends StatelessWidget {
  const TownLocationCard({
    super.key,
    required this.title,
    required this.image,
    required this.onTap,
    this.requiredLevel = 0,
    this.isUnlocked = true,
  });

  final String title;
  final String image;
  final void Function() onTap;
  final int requiredLevel;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: ColorFiltered(
        colorFilter: isUnlocked
            ? const ColorFilter.mode(Colors.transparent, BlendMode.color)
            : const ColorFilter.matrix(<double>[
                // R         G         B         A  Bias
                0.2126, 0.7152, 0.0722, 0, 0, // R'
                0.2126, 0.7152, 0.0722, 0, 0, // G'
                0.2126, 0.7152, 0.0722, 0, 0, // B'
                0, 0, 0, 1, 0, // A'
              ]),
        child: QVWhiteCard(
          onTap: () => {},
          padding: EdgeInsets.only(top: 40, bottom: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                isUnlocked ? image : 'images/pixel-icons/lock.png',
                width: 52,
                height: 52,
                filterQuality: FilterQuality.none,
              ),
              if (!isUnlocked)
                Text(
                  'Requires Level $requiredLevel',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'images/ui/buttons/white-button-filled-2x.png',
                    ),
                    centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.none,
                  ),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
