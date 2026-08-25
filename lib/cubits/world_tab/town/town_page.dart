import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/world_tab/town/character_stats_card.dart';
import 'package:questvale/cubits/world_tab/town/equipment_slot_sheet.dart';
import 'package:questvale/cubits/world_tab/town/forging/forge/forge_page.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/quest_board_page.dart';
import 'package:questvale/cubits/world_tab/town/skills_row.dart';
import 'package:questvale/cubits/world_tab/town/town_visit_sheet.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/widgets/qv_app_bar.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_card_border.dart';
import 'package:questvale/widgets/qv_fading_scrollable.dart';
import 'package:questvale/widgets/qv_picker_sheet.dart';
import 'package:questvale/widgets/qv_text_styles.dart';

/// Town Square: the permanent root of the World tab's town flow, and — per
/// the Combat & Questing Redesign ticket's second pass — now also where
/// gear/skill management lives. The AP system means this page is only ever
/// visited briefly and with intent, right after a quest: the player has new
/// gear/materials/levels to deal with and wants to fix their loadout and go
/// again, not browse a town menu. So the page leads with the character
/// (stats card), then the town destinations (Quest Board, Shop, etc.) right
/// below it, then gear (skills, equipment) — one scrollable list, styled
/// like the Todo tab's own item rows, replacing both the old button-grid
/// Town Square and the old two-tab Gear Up page.
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

    return Scaffold(
      body: Column(
        children: [
          QvAppBar(title: 'Town Square'),
          Expanded(
            child: Container(
              color: colorScheme.surface,
              child: QvFadingScrollable(
                child: ListView(
                  padding: const EdgeInsets.all(10),
                  children: [
                    const CharacterStatsCard(),
                    const _QuestBoardCard(),
                    const _TownLocationsCard(),
                    const SkillsRow(),
                    const _WeaponArtifactCard(),
                    const _EquipmentGridCard(),
                    const _PotionsRow(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentIcon extends StatelessWidget {
  const _EquipmentIcon({
    required this.equipment,
    required this.characterClass,
    this.size = 44,
    this.width,
    this.height,
  });

  final Equipment? equipment;
  final CharacterClass characterClass;

  // Square box (width == height == size) unless width/height are given
  // explicitly — used to widen an item to a rectangular shape (see
  // _WeaponArtifactCard) without changing the icon's own on-screen size.
  final double size;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final boxWidth = width ?? size;
    final boxHeight = height ?? size;
    // QvCardBorder's border+child Container shrink-wraps to padding+child
    // rather than filling the box it's given (see its own doc comment on
    // why — it's built to size itself off content, not stretch) — for a
    // square icon that's invisible, since padding+iconSize is tuned to add
    // up to `size` already. For a rectangular box (width != height) it
    // isn't: the child needs to actually BE boxWidth/boxHeight (minus
    // padding) for the border to visibly reach the box's real edges,
    // hence wrapping the icon in a SizedBox sized to fill the padded area
    // and centering the actual image within that instead of inside it.
    // 16 (wider than QvCardBorder's own 12px default, per feedback) — an
    // earlier, tighter 8 let the icon's own opaque pixels visually crowd/
    // overlap the rarity border's inner edge, since the border frame's
    // decoration paints across the full box while only `padding` insets the
    // child from it.
    const padding = 16.0;
    final iconSize = (boxHeight - padding * 2).clamp(0.0, double.infinity);
    return QvCardBorder(
      width: boxWidth,
      height: boxHeight,
      type: equipment == null
          ? QvCardBorderType.surface
          : QvCardBorderType.rarity,
      rarity: equipment?.rarity ?? Rarity.common,
      bgColor: colorScheme.surface,
      padding: const EdgeInsets.all(padding),
      child: SizedBox(
        width: boxWidth - padding * 2,
        height: boxHeight - padding * 2,
        child: equipment == null
            ? null
            : Center(
                child: Image.asset(
                  equipment!.iconPath(characterClass),
                  width: iconSize,
                  height: iconSize,
                  filterQuality: FilterQuality.none,
                  fit: BoxFit.contain,
                  scale: .1,
                ),
              ),
      ),
    );
  }
}

/// Every equipment slot except Weapon and Artifact — those two pair up in
/// their own card instead, see _WeaponArtifactCard below — one shared card,
/// icon-only grid, tap opens the same per-slot sheet as before. Per
/// feedback: Helmet/Chestplate/Gloves/Boots on the first row, Amulet/Ring
/// 1/Ring 2 on the second.
class _EquipmentGridCard extends StatelessWidget {
  const _EquipmentGridCard();

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final character = context.watch<PlayerCubit>().state.character;
    if (character == null) return const SizedBox.shrink();
    final characterClass = character.characterClass;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: QvButton(
        buttonColor: ButtonColor.surfaceContainer,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // No card-wide onTap here (each icon has its own), so this
            // header is a plain label — no trailing '>' chevron like
            // SkillsRow/_PotionsRow use for their single-destination rows.
            Text(
              'Equipment',
              style: QvTextStyles.sectionHeader
                  .copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 10),
            // Explicit per-item size via LayoutBuilder rather than
            // Row+Expanded — same reasoning as _TownLocationsCard's own doc
            // comment: this sidesteps a live centerSlice/BoxFit rendering
            // fragility that combination hit, regardless of whether that
            // fragility was actually caused by Expanded itself.
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 8.0;
                final itemSize = (constraints.maxWidth - spacing * 3) / 4;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: spacing,
                  children: [
                    Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        _EquipmentGridItem(
                          size: itemSize,
                          slot: EquipmentSlot.head,
                          label: 'Helmet',
                          equipment: character.equippedHelmet,
                          characterClass: characterClass,
                        ),
                        _EquipmentGridItem(
                          size: itemSize,
                          slot: EquipmentSlot.body,
                          label: 'Chestplate',
                          equipment: character.equippedChestplate,
                          characterClass: characterClass,
                        ),
                        _EquipmentGridItem(
                          size: itemSize,
                          slot: EquipmentSlot.hands,
                          label: 'Gloves',
                          equipment: character.equippedGloves,
                          characterClass: characterClass,
                        ),
                        _EquipmentGridItem(
                          size: itemSize,
                          slot: EquipmentSlot.feet,
                          label: 'Boots',
                          equipment: character.equippedBoots,
                          characterClass: characterClass,
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        _EquipmentGridItem(
                          size: itemSize,
                          slot: EquipmentSlot.neck,
                          label: 'Amulet',
                          equipment: character.equippedAmulet,
                          characterClass: characterClass,
                        ),
                        _EquipmentGridItem(
                          size: itemSize,
                          slot: EquipmentSlot.ring,
                          ringSlot: 1,
                          label: 'Ring 1',
                          equipment: character.equippedRing1,
                          characterClass: characterClass,
                        ),
                        _EquipmentGridItem(
                          size: itemSize,
                          slot: EquipmentSlot.ring,
                          ringSlot: 2,
                          label: 'Ring 2',
                          equipment: character.equippedRing2,
                          characterClass: characterClass,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Weapon and Artifact pair up in their own small card — same icon-only
/// treatment as _EquipmentGridCard, just the two of them, kept separate
/// since they're each a single stand-alone slot (not part of a
/// "helmet/chest/gloves/boots"-style set). Widened to fill the card
/// (roughly half its width each) rather than sized to match the 4-column
/// grid's smaller icons, per feedback — the icon itself stays a fixed,
/// reasonable size (see _EquipmentIcon/_ArtifactGridItem's width/height
/// params), just centered in a wider rarity-bordered box.
class _WeaponArtifactCard extends StatelessWidget {
  const _WeaponArtifactCard();

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final character = context.watch<PlayerCubit>().state.character;
    if (character == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: QvButton(
        buttonColor: ButtonColor.surfaceContainer,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Same plain-label treatment as _EquipmentGridCard's header —
            // no card-wide onTap to chevron toward, each icon has its own.
            Text(
              'Weapon & Artifact',
              style: QvTextStyles.sectionHeader
                  .copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 8.0;
                const itemHeight = 76.0;
                final itemWidth = (constraints.maxWidth - spacing) / 2;
                return Row(
                  spacing: spacing,
                  children: [
                    _EquipmentGridItem(
                      size: itemHeight,
                      width: itemWidth,
                      height: itemHeight,
                      slot: EquipmentSlot.weapon,
                      label: 'Weapon',
                      equipment: character.equippedWeapon,
                      characterClass: character.characterClass,
                    ),
                    _ArtifactGridItem(
                      size: itemHeight,
                      width: itemWidth,
                      height: itemHeight,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EquipmentGridItem extends StatelessWidget {
  const _EquipmentGridItem({
    required this.size,
    required this.slot,
    required this.label,
    required this.equipment,
    required this.characterClass,
    this.ringSlot,
    this.width,
    this.height,
  });

  final double size;
  final EquipmentSlot slot;
  final String label;
  final Equipment? equipment;
  final CharacterClass characterClass;
  final int? ringSlot;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    // QvCardBorder has no GestureDetector of its own (unlike QvButton/
    // QvSkillButton), so wrapping it directly in one here is safe — no
    // nested-GestureDetector footgun risk.
    return GestureDetector(
      onTap: () => showEquipmentSlotSheet(
        context,
        slot: slot,
        label: label,
        ringSlot: ringSlot,
      ),
      child: _EquipmentIcon(
        equipment: equipment,
        characterClass: characterClass,
        size: size,
        width: width,
        height: height,
      ),
    );
  }
}

/// Artifact has no real backend yet (no artifact system implemented
/// anywhere) — building one is new mechanics, out of scope for this
/// redesign ticket. Same "Coming Soon" placeholder treatment as the
/// still-unbuilt town destinations and Potions, just as a grid item here
/// instead of its own row.
class _ArtifactGridItem extends StatelessWidget {
  const _ArtifactGridItem({required this.size, this.width, this.height});

  final double size;

  // See _EquipmentIcon's doc comment on the same pair of params — same
  // "fill a rectangular box, not just a square" need, same fix.
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final boxWidth = width ?? size;
    final boxHeight = height ?? size;
    // See _EquipmentIcon's own doc comment on this same value/reasoning.
    const padding = 16.0;
    final iconSize = (boxHeight - padding * 2).clamp(0.0, double.infinity);
    return GestureDetector(
      onTap: () => QvPickerSheet.showModal(
        context,
        title: 'Artifact',
        body: const _ComingSoonBody(),
      ),
      child: QvCardBorder(
        width: boxWidth,
        height: boxHeight,
        type: QvCardBorderType.surface,
        bgColor: colorScheme.surface,
        padding: const EdgeInsets.all(padding),
        child: SizedBox(
          width: boxWidth - padding * 2,
          height: boxHeight - padding * 2,
          child: Center(
            child: Image.asset(
              'images/pixel-icons/artifact.png',
              width: iconSize,
              height: iconSize,
              filterQuality: FilterQuality.none,
              fit: BoxFit.contain,
              scale: .1,
            ),
          ),
        ),
      ),
    );
  }
}

/// Same "no real backend yet" situation as _ArtifactGridItem, but the 4 potion
/// slots collapse into one row — a compact icon strip, same treatment as
/// SkillsRow — rather than 4 separate rows, per feedback.
class _PotionsRow extends StatelessWidget {
  const _PotionsRow();

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: QvButton(
        buttonColor: ButtonColor.surfaceContainer,
        padding: const EdgeInsets.all(12),
        onTap: () => QvPickerSheet.showModal(
          context,
          title: 'Potions',
          body: const _ComingSoonBody(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Plain label, no trailing '>' — matches the Equipment/Weapon &
            // Artifact cards' header treatment even though this row (unlike
            // those two) does have one card-wide onTap; kept for visual
            // consistency across all four grid-style cards per feedback.
            Text(
              'Potions',
              style: QvTextStyles.sectionHeader
                  .copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 10),
            // Explicit per-item size via LayoutBuilder, filling the row
            // edge-to-edge — same treatment as the Equipment and Weapon &
            // Artifact grids, replacing the old fixed-36px/spaceEvenly icons.
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 8.0;
                const padding = 6.0;
                final itemSize = (constraints.maxWidth - spacing * 3) / 4;
                final iconSize =
                    (itemSize - padding * 2).clamp(0.0, double.infinity);
                return Row(
                  spacing: spacing,
                  children: List.generate(
                    4,
                    (_) => QvCardBorder(
                      width: itemSize,
                      height: itemSize,
                      type: QvCardBorderType.surface,
                      bgColor: colorScheme.surface,
                      padding: const EdgeInsets.all(padding),
                      child: Image.asset(
                        'images/pixel-icons/potion-star.png',
                        width: iconSize,
                        height: iconSize,
                        filterQuality: FilterQuality.none,
                        fit: BoxFit.contain,
                        scale: .1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Quest Board is the single most important action on this page (per the
/// ticket's own rationale: the AP loop is "fix loadout, go again," and
/// Quest Board is "go again") — it gets its own standalone list item
/// instead of sharing one with the other six destinations below, per
/// feedback. Same icon+text treatment _TownLocationButton uses, just as
/// its own directly-tappable QvButton — `primary` (per feedback, to stand
/// out from every other standalone list item on this page, which stay
/// `surfaceContainer`) rather than nested inside a decorative wrapper —
/// always unlocked, so no ColorFiltered/level-gate dance is needed here.
class _QuestBoardCard extends StatelessWidget {
  const _QuestBoardCard();

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: QvButton(
        buttonColor: ButtonColor.primary,
        onTap: () => TownVisitSheet.showModal(
          context,
          title: 'Quest Board',
          iconPath: 'images/pixel-icons/portal.png',
          body: const QuestBoardPage(),
        ),
        height: 76,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'images/pixel-icons/portal.png',
              width: 28,
              height: 28,
              filterQuality: FilterQuality.none,
              fit: BoxFit.contain,
              scale: .1,
            ),
            const SizedBox(width: 8),
            Text(
              'Quest Board',
              style: QvTextStyles.sectionTitle
                  .copyWith(color: colorScheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

/// The remaining 6 town destinations (Quest Board split out into its own
/// _QuestBoardCard above, per feedback) share one card — individual
/// buttons inside a single list item, paired 2-per-row in a Wrap, same
/// grouping the original button-grid Town Square used. Deliberately
/// explicit per-button width (via LayoutBuilder) rather than
/// Row+Expanded+stretch — that combination, nested this deep inside
/// QvButton's own centerSlice border decoration, hit a real Flutter
/// layout/paint bug live (every QvCardBorder/QvButton border elsewhere on
/// the page started throwing "centerSlice was used with a BoxFit that
/// does not guarantee the image is fully visible" once this card scrolled
/// into view) — explicit sizing sidesteps it the same way every other icon
/// box on this page already avoids Expanded/Flex ambiguity.
class _TownLocationsCard extends StatelessWidget {
  const _TownLocationsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: QvButton(
        buttonColor: ButtonColor.surfaceContainer,
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const pairSpacing = 8.0;
            final pairWidth = (constraints.maxWidth - pairSpacing) / 2;
            return Wrap(
              spacing: pairSpacing,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: pairWidth,
                  child: _TownLocationButton(
                    title: 'Shop',
                    iconPath: 'images/pixel-icons/all-coins-stack.png',
                    onTap: () => _showComingSoonDestination(
                      context,
                      title: 'Shop',
                      iconPath: 'images/pixel-icons/all-coins-stack.png',
                    ),
                  ),
                ),
                SizedBox(
                  width: pairWidth,
                  child: _TownLocationButton(
                    title: 'Guild Hall',
                    iconPath: 'images/pixel-icons/letter.png',
                    onTap: () => _showComingSoonDestination(
                      context,
                      title: 'Guild Hall',
                      iconPath: 'images/pixel-icons/letter.png',
                    ),
                  ),
                ),
                SizedBox(
                  width: pairWidth,
                  child: _TownLocationButton(
                    title: 'Forge',
                    iconPath: 'images/pixel-icons/anvil-hammer-star.png',
                    requiredLevel: 10,
                    onTap: () => TownVisitSheet.showModal(
                      context,
                      title: 'Forge',
                      iconPath: 'images/pixel-icons/anvil-hammer-star.png',
                      body: const ForgePage(),
                    ),
                  ),
                ),
                SizedBox(
                  width: pairWidth,
                  child: _TownLocationButton(
                    title: 'Lab',
                    iconPath: 'images/pixel-icons/potion-star.png',
                    requiredLevel: 20,
                    onTap: () => _showComingSoonDestination(
                      context,
                      title: 'Lab',
                      iconPath: 'images/pixel-icons/potion-star.png',
                    ),
                  ),
                ),
                SizedBox(
                  width: pairWidth,
                  child: _TownLocationButton(
                    title: 'Gemforge',
                    iconPath: 'images/pixel-icons/jewel-star.png',
                    requiredLevel: 40,
                    onTap: () => _showComingSoonDestination(
                      context,
                      title: 'Gemforge',
                      iconPath: 'images/pixel-icons/jewel-star.png',
                    ),
                  ),
                ),
                SizedBox(
                  width: pairWidth,
                  child: _TownLocationButton(
                    title: 'Reliquary',
                    iconPath: 'images/pixel-icons/artifact.png',
                    requiredLevel: 80,
                    onTap: () => _showComingSoonDestination(
                      context,
                      title: 'Reliquary',
                      iconPath: 'images/pixel-icons/artifact.png',
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TownLocationButton extends StatelessWidget {
  const _TownLocationButton({
    required this.title,
    required this.iconPath,
    required this.onTap,
    this.requiredLevel = 0,
  });

  final String title;
  final String iconPath;
  final int requiredLevel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final character = context.watch<PlayerCubit>().state.character;
    final isUnlocked = character != null && character.level >= requiredLevel;

    // Nested inside _TownLocationsCard's own decorative (no-op) QvButton —
    // safe because the innermost GestureDetector in a hit-test chain wins
    // the gesture arena for a simple tap (see the nested-GestureDetector
    // footgun this codebase has hit — and fixed — the other way around,
    // e.g. SkillsRow's _SkillSlotIcon), so this button's own onTap fires
    // correctly rather than the outer card's inert one.
    return ColorFiltered(
      colorFilter: isUnlocked
          ? const ColorFilter.mode(Colors.transparent, BlendMode.color)
          : const ColorFilter.matrix(<double>[
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
            ]),
      child: QvButton(
        buttonColor: ButtonColor.surface,
        onTap: onTap,
        height: 76,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconPath,
              width: 28,
              height: 28,
              filterQuality: FilterQuality.none,
              fit: BoxFit.contain,
              scale: .1,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                isUnlocked ? title : 'Lv $requiredLevel',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: QvTextStyles.sectionTitle
                    .copyWith(color: colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showComingSoonDestination(
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
          style: QvTextStyles.title
              .copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
      ),
    );
  }
}
