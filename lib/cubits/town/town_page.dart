import 'package:flutter/material.dart';
import 'package:questvale/cubits/select_quest/select_quest_page.dart';
import 'package:questvale/widgets/qv_app_bar.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_white_card.dart';

class TownPage extends StatelessWidget {
  const TownPage({super.key, required this.onQuestCreated});
  final Function() onQuestCreated;

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
                spacing: 4,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.125,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: padding, right: padding),
                      child: QVWhiteCard(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectQuestPage(
                                onQuestCreated: onQuestCreated,
                              ),
                            ),
                          )
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
                  SizedBox(height: 4),
                  Container(
                      height: 4,
                      width: MediaQuery.of(context).size.width * 0.85,
                      color: colorScheme.secondary),
                  SizedBox(height: 4),
                  SizedBox(
                    height: 140,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: padding, right: padding),
                      child: Row(
                        spacing: 8,
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
                            title: 'Guild Hall',
                            image: 'images/pixel-icons/letter.png',
                            onTap: () => {},
                            requiredLevel: 0,
                            isUnlocked: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 140,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: padding, right: padding),
                      child: Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TownLocationCard(
                            title: 'Lab',
                            image: 'images/pixel-icons/potion-star.png',
                            onTap: () => {},
                            requiredLevel: 10,
                            isUnlocked: false,
                          ),
                          TownLocationCard(
                            title: 'Forge',
                            image: 'images/pixel-icons/anvil-hammer-star.png',
                            onTap: () => {},
                            requiredLevel: 20,
                            isUnlocked: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 140,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: padding, right: padding),
                      child: Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TownLocationCard(
                            title: 'Gemforge',
                            image: 'images/pixel-icons/jewel-star.png',
                            onTap: () => {},
                            requiredLevel: 40,
                            isUnlocked: false,
                          ),
                          TownLocationCard(
                            title: 'Reliquary',
                            image: 'images/pixel-icons/artifact.png',
                            onTap: () => {},
                            requiredLevel: 80,
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
          padding: EdgeInsets.only(top: 20, bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                image,
                width: 48,
                height: 48,
                scale: .1,
                filterQuality: FilterQuality.none,
              ),
              SizedBox(height: 8),
              QvButton(
                buttonColor: ButtonColor.primary,
                child: Text(
                  isUnlocked ? title : 'Level $requiredLevel',
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
