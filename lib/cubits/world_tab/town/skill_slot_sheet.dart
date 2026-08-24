import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/skills_gear_up/skills_gear_up_cubit.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/skills_gear_up/skills_gear_up_state.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/widgets/qv_card_border.dart';
import 'package:questvale/widgets/qv_fading_scrollable.dart';
import 'package:questvale/widgets/qv_picker_sheet.dart';
import 'package:questvale/widgets/qv_skill_button.dart';
import 'package:sqflite/sqflite.dart';

// Opens a lightweight picker sheet for one active-skill loadout slot —
// mirrors equipment_slot_sheet.dart's shape/reasoning exactly, just for
// skills: reuses SkillsGearUpCubit's data layer (assignSkillToSlot/
// clearLoadoutSlot) and SkillSlotAssignmentList's owned-actives picker
// rather than duplicating either. Scoped to a single slot from the moment
// it opens, same as the equipment sheet. This is now the one modal used
// for tapping a skill slot everywhere it appears — Town Square's SkillsRow
// and the full Skill Tree page's own Loadout section both open it, instead
// of the Skill Tree page swapping its own body in place.
Future<void> showSkillSlotSheet(BuildContext context, {required int slotNumber}) {
  final character = context.read<PlayerCubit>().state.character!;
  final db = context.read<Database>();
  final gameData = context.read<GameData>();
  final playerCubit = context.read<PlayerCubit>();
  return QvPickerSheet.showModal(
    context,
    title: 'Slot $slotNumber',
    body: BlocProvider<SkillsGearUpCubit>(
      create: (context) => SkillsGearUpCubit(
        db: db,
        gameData: gameData,
        playerCubit: playerCubit,
        character: character,
      ),
      child: Builder(
        builder: (context) => SkillSlotAssignmentList(
          slotNumber: slotNumber,
          onAssigned: () => Navigator.of(context).pop(),
        ),
      ),
    ),
  );
}

// The owned-actives picker for one loadout slot — a "Clear Slot" entry (if
// it's currently occupied) followed by every active skill the character
// owns, tapping one assigns it via SkillsGearUpCubit. onAssigned fires
// after a successful assign/clear so the caller can close whatever's
// hosting this (showSkillSlotSheet above pops the sheet).
class SkillSlotAssignmentList extends StatelessWidget {
  final int slotNumber;
  final VoidCallback? onAssigned;
  const SkillSlotAssignmentList({super.key, required this.slotNumber, this.onAssigned});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gameData = context.read<GameData>();
    return BlocBuilder<SkillsGearUpCubit, SkillsGearUpState>(
      builder: (context, state) {
        final cubit = context.read<SkillsGearUpCubit>();
        final character = state.character;
        final ownedActives = character.skills
            .where(
                (cs) => gameData.getSkillDataById(cs.skillId).type == SkillType.active)
            .toList();
        final currentlyAssigned = character.activeSkillSlotAt(slotNumber);

        // Which slot (if any) each owned active is already sitting in — so
        // a skill assigned elsewhere can be labeled "move" rather than
        // silently relocated with no warning when tapped. A skill can only
        // ever occupy one slot (Character.copyWithActiveSkillSlot enforces
        // this), so this is at most a 1:1 map.
        final assignedSlotBySkillId = <String, int>{
          for (var slot = 1; slot <= 5; slot++)
            if (character.activeSkillSlotAt(slot) != null)
              character.activeSkillSlotAt(slot)!.skillId: slot,
        };

        return QvFadingScrollable(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              if (currentlyAssigned != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GestureDetector(
                    onTap: () async {
                      await cubit.clearLoadoutSlot(slotNumber);
                      onAssigned?.call();
                    },
                    child: QvCardBorder(
                      type: QvCardBorderType.surface,
                      padding: const EdgeInsets.all(8),
                      child: SizedBox(
                        height: 48,
                        child: Center(
                          child: Text('Clear Slot',
                              style: TextStyle(color: colorScheme.onSurface)),
                        ),
                      ),
                    ),
                  ),
                ),
              if (ownedActives.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text('No active skills owned yet',
                        style: TextStyle(color: colorScheme.onSurface)),
                  ),
                ),
              for (final characterSkill in ownedActives)
                Builder(builder: (context) {
                  final skillData =
                      gameData.getSkillDataById(characterSkill.skillId);
                  final assignedElsewhere =
                      assignedSlotBySkillId[characterSkill.skillId];
                  final label = assignedElsewhere != null &&
                          assignedElsewhere != slotNumber
                      ? '${skillData.name} (Lv ${characterSkill.level}) — move from Slot $assignedElsewhere'
                      : '${skillData.name} (Lv ${characterSkill.level})';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: GestureDetector(
                      onTap: () async {
                        await cubit.assignSkillToSlot(slotNumber, characterSkill);
                        onAssigned?.call();
                      },
                      child: QvCardBorder(
                        type: QvCardBorderType.surface,
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            QvSkillButton(
                              width: 48,
                              height: 48,
                              skillIconPath: skillData.iconPath,
                              skillButtonColor: skillData.buttonColor,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(label,
                                  style: TextStyle(color: colorScheme.onSurface)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}
