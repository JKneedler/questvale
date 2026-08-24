import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/skills_gear_up/skills_gear_up_cubit.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/skills_gear_up/skills_gear_up_page.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/widgets/qv_picker_sheet.dart';
import 'package:sqflite/sqflite.dart';

// Opens a lightweight picker sheet for one active-skill loadout slot —
// mirrors equipment_slot_sheet.dart's shape/reasoning exactly, just for
// skills: reuses SkillsGearUpCubit's data layer (assignSkillToSlot/
// clearLoadoutSlot) and SkillSlotAssignmentList's owned-actives picker
// (also shared with the full Skill Tree page's in-place loadout swap)
// rather than duplicating either. Scoped to a single slot from the moment
// it opens, same as the equipment sheet — the full tier grid/unlock flow
// lives one level up now, behind SkillsRow's separate "Skill Tree" button.
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
