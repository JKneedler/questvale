import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/nav_aware_modal_sheet.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/skills_gear_up/skills_gear_up_page.dart';
import 'package:questvale/cubits/world_tab/town/skill_slot_sheet.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/widgets/qv_skill_button.dart';
import 'package:jk_pixel_ui/jk_pixel_ui.dart';

// Opens SkillsGearUpPage's tier grid (browsing/unlocking/upgrading skills;
// its own Loadout section was dropped as redundant with this row, see the
// Combat & Questing Redesign ticket) in a picker sheet — wrapped in a
// Column since SkillsGearUpPage's own root is `Expanded(child: ...)`, which
// needs a Flex ancestor to size against (QvPickerSheet's
// scrollableBody: false gives it a bounded Positioned.fill, not a Flex, on
// its own). This is now SkillsRow's "Skill Tree" button's destination —
// browsing/unlocking skills moved off the row itself, see the row's own
// doc comment.
void showSkillsSheet(BuildContext context) {
  showQvPickerSheetModal(
    context,
    title: 'Skills',
    body: const Column(children: [SkillsGearUpPage()]),
  );
}

// One row, directly below the character stats card — a compact preview of
// the current 5-slot active loadout. No card-wide onTap (matches the
// Equipment/Weapon & Artifact cards' plain-label header) — per feedback,
// each slot icon is its own tap target that opens a picker scoped to just
// that slot (showSkillSlotSheet — owned actives only, not the full tree),
// and browsing/unlocking the tree moved to its own "Skill Tree" button
// below the icons. See the Combat & Questing Redesign ticket.
class SkillsRow extends StatelessWidget {
  const SkillsRow({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final playerSkills = context.watch<PlayerCubit>().state.playerSkills;
    final slots = [
      playerSkills?.activeSkillSlot1,
      playerSkills?.activeSkillSlot2,
      playerSkills?.activeSkillSlot3,
      playerSkills?.activeSkillSlot4,
      playerSkills?.activeSkillSlot5,
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: QvButton(
        buttonColor: ButtonColor.surfaceContainer,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Skills',
              style: QvTextStyles.sectionHeader
                  .copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 10),
            // Explicit per-item size via LayoutBuilder, filling the row
            // edge-to-edge — same treatment as the Equipment and Weapon &
            // Artifact grids.
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 8.0;
                final itemSize = (constraints.maxWidth - spacing * 4) / 5;
                return Row(
                  spacing: spacing,
                  children: [
                    for (var i = 0; i < slots.length; i++)
                      _SkillSlotIcon(
                        skill: slots[i],
                        size: itemSize,
                        slotNumber: i + 1,
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            QvButton(
              width: double.infinity,
              height: 44,
              buttonColor: ButtonColor.surface,
              onTap: () => showSkillsSheet(context),
              child: Center(
                child: Text(
                  'Skill Tree',
                  style: QvTextStyles.sectionTitle
                      .copyWith(color: colorScheme.onSurface),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillSlotIcon extends StatelessWidget {
  const _SkillSlotIcon({
    required this.skill,
    required this.size,
    required this.slotNumber,
  });

  final BaseActiveSkill? skill;
  final double size;
  final int slotNumber;

  @override
  Widget build(BuildContext context) {
    // Tapping any slot — filled or empty — opens a picker scoped to just
    // this slot (see skill_slot_sheet.dart), not the whole skill tree.
    // QvSkillButton/plain Container+GestureDetector each own their tap
    // directly here; no outer row-level GestureDetector exists anymore to
    // fight over the gesture arena.
    if (skill == null) {
      return GestureDetector(
        onTap: () => showSkillSlotSheet(context, slotNumber: slotNumber),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }
    return QvSkillButton(
      width: size,
      height: size,
      skillIconPath: skill!.data.iconPath,
      skillButtonColor: skill!.data.buttonColor,
      onTap: () => showSkillSlotSheet(context, slotNumber: slotNumber),
    );
  }
}
