import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/skills_gear_up/skills_gear_up_page.dart';
import 'package:questvale/data/skills/base_active_skill.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_picker_sheet.dart';
import 'package:questvale/widgets/qv_skill_button.dart';

// Opens the exact same SkillsGearUpPage content (loadout section + tier
// grid, unchanged since the Skills UI ticket) in a picker sheet — wrapped
// in a Column since SkillsGearUpPage's own root is `Expanded(child: ...)`,
// which needs a Flex ancestor to size against (QvPickerSheet's
// scrollableBody: false gives it a bounded Positioned.fill, not a Flex, on
// its own).
void showSkillsSheet(BuildContext context) {
  QvPickerSheet.showModal(
    context,
    title: 'Skills',
    body: const Column(children: [SkillsGearUpPage()]),
  );
}

// One row, directly below the character stats card — a compact preview of
// the current 5-slot active loadout. Deliberately more prominent than a
// small leading-icon row (its own full-width icon strip instead) since
// this is the single entry point for both reassigning the loadout and
// browsing/unlocking the skill tree. See the Combat & Questing Redesign
// ticket.
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
        onTap: () => showSkillsSheet(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Skills',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Text('>',
                    style: TextStyle(fontSize: 20, color: colorScheme.onSurface)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final skill in slots) _SkillSlotIcon(skill: skill),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillSlotIcon extends StatelessWidget {
  const _SkillSlotIcon({required this.skill});

  final BaseActiveSkill? skill;

  @override
  Widget build(BuildContext context) {
    if (skill == null) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }
    // Decorative only — the whole row is what opens the sheet (see
    // SkillsRow's outer QvButton). QvSkillButton wraps its own child in a
    // GestureDetector regardless of whether onTap is passed (defaults to a
    // no-op), which would otherwise win the gesture arena over the outer
    // QvButton's own detector and silently eat the tap (the same nested-
    // GestureDetector footgun this codebase has hit — and fixed — before).
    // IgnorePointer keeps this icon out of hit-testing entirely so the tap
    // passes through to the row.
    return IgnorePointer(
      child: QvSkillButton(
        width: 36,
        height: 36,
        skillIconPath: skill!.data.iconPath,
        skillButtonColor: skill!.data.buttonColor,
      ),
    );
  }
}
