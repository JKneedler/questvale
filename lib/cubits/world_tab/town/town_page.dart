import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/world_tab/town/forging/forge/forge_page.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/quest_board_page.dart';
import 'package:questvale/cubits/world_tab/town/town_visit_sheet.dart';
import 'package:questvale/widgets/qv_app_bar.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_metal_corner_border.dart';
import 'package:questvale/widgets/qv_white_card.dart';

/// Town Square is now the permanent root of the World tab's town flow —
/// every destination (Quest Board, Shop, Guild Hall, Forge, Lab, Gemforge,
/// Reliquary) opens as a TownVisitSheet on top of it instead of the old
/// TownCubit/TownLocation full-page slide-swap. See the Combat & Questing
/// Redesign ticket.
class TownPage extends StatelessWidget {
  const TownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TownSquare();
  }
}

class TownSquare extends StatelessWidget {
  const TownSquare({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    const padding = 16.0;

    return Scaffold(
      body: Column(
        children: [
          QvAppBar(title: 'Town Square'),
          Expanded(
            child: Column(
              children: [
                Container(
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
                          padding: const EdgeInsets.only(
                              left: padding, right: padding),
                          child: GestureDetector(
                            onTap: () => TownVisitSheet.showModal(
                              context,
                              title: 'Quest Board',
                              iconPath: 'images/pixel-icons/portal.png',
                              body: const QuestBoardPage(),
                            ),
                            child: QvMetalCornerBorder(
                              padding: EdgeInsets.only(
                                  left: 52, right: 52, top: 30, bottom: 30),
                              color: colorScheme.secondary,
                              child: Row(
                                spacing: 16,
                                children: [
                                  Image.asset(
                                    'images/pixel-icons/portal.png',
                                    filterQuality: FilterQuality.none,
                                  ),
                                  Text(
                                    'Quest Board',
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
                          padding: const EdgeInsets.only(
                              left: padding, right: padding),
                          child: Row(
                            spacing: 8,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TownLocationCard(
                                title: 'Shop',
                                image: 'images/pixel-icons/all-coins-stack.png',
                                requiredLevel: 0,
                                onVisit: () => _showComingSoon(
                                  context,
                                  title: 'Shop',
                                  iconPath:
                                      'images/pixel-icons/all-coins-stack.png',
                                ),
                              ),
                              TownLocationCard(
                                title: 'Guild Hall',
                                image: 'images/pixel-icons/letter.png',
                                requiredLevel: 0,
                                onVisit: () => _showComingSoon(
                                  context,
                                  title: 'Guild Hall',
                                  iconPath: 'images/pixel-icons/letter.png',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 140,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: padding, right: padding),
                          child: Row(
                            spacing: 8,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TownLocationCard(
                                title: 'Forge',
                                image:
                                    'images/pixel-icons/anvil-hammer-star.png',
                                requiredLevel: 10,
                                onVisit: () => TownVisitSheet.showModal(
                                  context,
                                  title: 'Forge',
                                  iconPath:
                                      'images/pixel-icons/anvil-hammer-star.png',
                                  body: const ForgePage(),
                                ),
                              ),
                              TownLocationCard(
                                title: 'Lab',
                                image: 'images/pixel-icons/potion-star.png',
                                requiredLevel: 20,
                                onVisit: () => _showComingSoon(
                                  context,
                                  title: 'Lab',
                                  iconPath: 'images/pixel-icons/potion-star.png',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 140,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: padding, right: padding),
                          child: Row(
                            spacing: 8,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TownLocationCard(
                                title: 'Gemforge',
                                image: 'images/pixel-icons/jewel-star.png',
                                requiredLevel: 40,
                                onVisit: () => _showComingSoon(
                                  context,
                                  title: 'Gemforge',
                                  iconPath: 'images/pixel-icons/jewel-star.png',
                                ),
                              ),
                              TownLocationCard(
                                title: 'Reliquary',
                                image: 'images/pixel-icons/artifact.png',
                                requiredLevel: 80,
                                onVisit: () => _showComingSoon(
                                  context,
                                  title: 'Reliquary',
                                  iconPath: 'images/pixel-icons/artifact.png',
                                ),
                              ),
                            ],
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
    );
  }
}

/// Shop/Guild Hall/Lab/Gemforge/Reliquary have no real functionality behind
/// them yet — building that is new mechanics, out of scope for this
/// redesign ticket. They still get the same TownVisitSheet arrival shell
/// now, so whichever ticket eventually builds each one's real content
/// inherits the pattern for free instead of needing its own navigation
/// rework later.
void _showComingSoon(
  BuildContext context, {
  required String title,
  required String iconPath,
}) {
  TownVisitSheet.showModal(
    context,
    title: title,
    iconPath: iconPath,
    body: const _ComingSoonBody(),
  );
}

class _ComingSoonBody extends StatelessWidget {
  const _ComingSoonBody();

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 200,
      child: Center(
        child: Text(
          'Coming Soon',
          style: TextStyle(
            fontSize: 24,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

class TownLocationCard extends StatelessWidget {
  const TownLocationCard({
    super.key,
    required this.title,
    required this.image,
    required this.onVisit,
    this.requiredLevel = 0,
  });

  final String title;
  final String image;
  final int requiredLevel;
  final VoidCallback onVisit;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    final character = context.read<PlayerCubit>().state.character;
    final isUnlocked = character != null && character.level >= requiredLevel;

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
          onTap: onVisit,
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
                onTap: onVisit,
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
