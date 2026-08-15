import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/world_tab/town/character_stats_card.dart';
import 'package:questvale/cubits/world_tab/town/equipment_slot_sheet.dart';
import 'package:questvale/cubits/world_tab/town/forging/forge/forge_page.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/quest_board_page.dart';
import 'package:questvale/cubits/world_tab/town/skills_row.dart';
import 'package:questvale/cubits/world_tab/town/town_list_row.dart';
import 'package:questvale/cubits/world_tab/town/town_visit_sheet.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/equipment.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/widgets/qv_app_bar.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_card_border.dart';
import 'package:questvale/widgets/qv_fading_scrollable.dart';
import 'package:questvale/widgets/qv_picker_sheet.dart';

String _capitalize(String value) =>
    value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

/// Town Square: the permanent root of the World tab's town flow, and — per
/// the Combat & Questing Redesign ticket's second pass — now also where
/// gear/skill management lives. The AP system means this page is only ever
/// visited briefly and with intent, right after a quest: the player has new
/// gear/materials/levels to deal with and wants to fix their loadout and go
/// again, not browse a town menu. So the page leads with the character
/// (stats card, skills), then gear, then the town destinations (Quest
/// Board, Shop, etc.) at the bottom — one scrollable list, styled like the
/// Todo tab's own item rows, replacing both the old button-grid Town Square
/// and the old two-tab Gear Up page.
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
                    const SkillsRow(),
                    const _EquipmentRow(
                        slot: EquipmentSlot.weapon, label: 'Weapon'),
                    const _EquipmentRow(
                        slot: EquipmentSlot.head, label: 'Helmet'),
                    const _EquipmentRow(
                        slot: EquipmentSlot.body, label: 'Chestplate'),
                    const _EquipmentRow(
                        slot: EquipmentSlot.hands, label: 'Gloves'),
                    const _EquipmentRow(
                        slot: EquipmentSlot.feet, label: 'Boots'),
                    const _EquipmentRow(
                        slot: EquipmentSlot.neck, label: 'Amulet'),
                    const _EquipmentRow(
                        slot: EquipmentSlot.ring, label: 'Ring 1', ringSlot: 1),
                    const _EquipmentRow(
                        slot: EquipmentSlot.ring, label: 'Ring 2', ringSlot: 2),
                    _ComingSoonRow(
                      title: 'Artifact',
                      iconPath: 'images/pixel-icons/artifact.png',
                    ),
                    const _PotionsRow(),
                    _TownLocationRow(
                      title: 'Quest Board',
                      iconPath: 'images/pixel-icons/portal.png',
                      onTap: () => TownVisitSheet.showModal(
                        context,
                        title: 'Quest Board',
                        iconPath: 'images/pixel-icons/portal.png',
                        body: const QuestBoardPage(),
                      ),
                    ),
                    _TownLocationRow(
                      title: 'Shop',
                      iconPath: 'images/pixel-icons/all-coins-stack.png',
                      onTap: () => _showComingSoonDestination(
                        context,
                        title: 'Shop',
                        iconPath: 'images/pixel-icons/all-coins-stack.png',
                      ),
                    ),
                    _TownLocationRow(
                      title: 'Guild Hall',
                      iconPath: 'images/pixel-icons/letter.png',
                      onTap: () => _showComingSoonDestination(
                        context,
                        title: 'Guild Hall',
                        iconPath: 'images/pixel-icons/letter.png',
                      ),
                    ),
                    _TownLocationRow(
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
                    _TownLocationRow(
                      title: 'Lab',
                      iconPath: 'images/pixel-icons/potion-star.png',
                      requiredLevel: 20,
                      onTap: () => _showComingSoonDestination(
                        context,
                        title: 'Lab',
                        iconPath: 'images/pixel-icons/potion-star.png',
                      ),
                    ),
                    _TownLocationRow(
                      title: 'Gemforge',
                      iconPath: 'images/pixel-icons/jewel-star.png',
                      requiredLevel: 40,
                      onTap: () => _showComingSoonDestination(
                        context,
                        title: 'Gemforge',
                        iconPath: 'images/pixel-icons/jewel-star.png',
                      ),
                    ),
                    _TownLocationRow(
                      title: 'Reliquary',
                      iconPath: 'images/pixel-icons/artifact.png',
                      requiredLevel: 80,
                      onTap: () => _showComingSoonDestination(
                        context,
                        title: 'Reliquary',
                        iconPath: 'images/pixel-icons/artifact.png',
                      ),
                    ),
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

class _EquipmentRow extends StatelessWidget {
  const _EquipmentRow({required this.slot, required this.label, this.ringSlot});

  final EquipmentSlot slot;
  final String label;
  final int? ringSlot;

  Equipment? _equippedItem(Character character) {
    if (slot == EquipmentSlot.ring) {
      return ringSlot == 2 ? character.equippedRing2 : character.equippedRing1;
    }
    return character.equippedForSlot(slot);
  }

  @override
  Widget build(BuildContext context) {
    final character = context.watch<PlayerCubit>().state.character;
    if (character == null) return const SizedBox.shrink();
    final equipment = _equippedItem(character);
    final subtitle = equipment == null
        ? 'Empty'
        : '${_capitalize(equipment.rarity.name)} '
            '${equipment.type.className(character.characterClass)}';

    return TownListRow(
      leading: _EquipmentIcon(
          equipment: equipment, characterClass: character.characterClass),
      title: label,
      subtitle: subtitle,
      onTap: () => showEquipmentSlotSheet(
        context,
        slot: slot,
        label: label,
        ringSlot: ringSlot,
      ),
    );
  }
}

class _EquipmentIcon extends StatelessWidget {
  const _EquipmentIcon({required this.equipment, required this.characterClass});

  final Equipment? equipment;
  final CharacterClass characterClass;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return QvCardBorder(
      width: 44,
      height: 44,
      type:
          equipment == null ? QvCardBorderType.surface : QvCardBorderType.rarity,
      rarity: equipment?.rarity ?? Rarity.common,
      bgColor: colorScheme.surface,
      padding: const EdgeInsets.all(6),
      child: equipment == null
          ? const SizedBox.shrink()
          : Image.asset(
              equipment!.iconPath(characterClass),
              width: 32,
              height: 32,
              filterQuality: FilterQuality.none,
              fit: BoxFit.contain,
              scale: .1,
            ),
    );
  }
}

/// Artifact/Potions have no real backend yet (no artifact or potion system
/// implemented anywhere) — building one is new mechanics, out of scope for
/// this redesign ticket. Same "Coming Soon" placeholder treatment as the
/// still-unbuilt town destinations, just reached via the lighter picker
/// sheet since these aren't "a place" either.
class _ComingSoonRow extends StatelessWidget {
  const _ComingSoonRow({required this.title, required this.iconPath});

  final String title;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return TownListRow(
      leading: QvCardBorder(
        width: 44,
        height: 44,
        type: QvCardBorderType.surface,
        bgColor: colorScheme.surface,
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          iconPath,
          width: 28,
          height: 28,
          filterQuality: FilterQuality.none,
          fit: BoxFit.contain,
          scale: .1,
        ),
      ),
      title: title,
      subtitle: 'Coming Soon',
      onTap: () => QvPickerSheet.showModal(
        context,
        title: title,
        body: const _ComingSoonBody(),
      ),
    );
  }
}

/// Same "no real backend yet" situation as _ComingSoonRow, but the 4 potion
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
            Row(
              children: [
                Text(
                  'Potions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Text('>',
                    style:
                        TextStyle(fontSize: 20, color: colorScheme.onSurface)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                4,
                (_) => QvCardBorder(
                  width: 36,
                  height: 36,
                  type: QvCardBorderType.surface,
                  bgColor: colorScheme.surface,
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    'images/pixel-icons/potion-star.png',
                    width: 22,
                    height: 22,
                    filterQuality: FilterQuality.none,
                    fit: BoxFit.contain,
                    scale: .1,
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

class _TownLocationRow extends StatelessWidget {
  const _TownLocationRow({
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

    return TownListRow(
      leading: QvCardBorder(
        width: 44,
        height: 44,
        type: QvCardBorderType.surface,
        bgColor: colorScheme.surface,
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          iconPath,
          width: 28,
          height: 28,
          filterQuality: FilterQuality.none,
          fit: BoxFit.contain,
          scale: .1,
        ),
      ),
      title: title,
      subtitle: isUnlocked ? null : 'Unlocks at Level $requiredLevel',
      locked: !isUnlocked,
      onTap: onTap,
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
          style: TextStyle(
            fontSize: 24,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
