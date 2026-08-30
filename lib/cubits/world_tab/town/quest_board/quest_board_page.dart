import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/quest_board_cubit.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/quest_board_state.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/select_quest/select_quest_page.dart';
import 'package:questvale/cubits/world_tab/world_cubit.dart';
import 'package:sqflite/sqflite.dart';

class QuestBoardPage extends StatelessWidget {
  const QuestBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuestBoardCubit>(
      create: (context) => QuestBoardCubit(db: context.read<Database>()),
      child: const QuestBoardView(),
    );
  }
}

// Just the zone list now — see QuestBoardCubit's own doc comment. No more
// internal page-swap to a Gear Up step (gear/skills live on Town Square's
// own list now), so this no longer needs QvAnimatedTransition either.
class QuestBoardView extends StatelessWidget {
  const QuestBoardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuestBoardCubit, QuestBoardState>(
      listenWhen: (prev, next) =>
          next.questBoardState == QuestBoardStates.questCreated,
      listener: (context, questBoardState) {
        context.read<WorldCubit>().onQuestCreated();
        // Quest Board is a modal sheet, not a full page — once WorldCubit
        // has swapped WorldView's underlying display over to
        // QuestEncounterPage, close the sheet so that page is actually
        // visible instead of sitting hidden underneath it.
        Navigator.of(context).pop();
      },
      builder: (context, questBoardState) => const SelectQuestPage(),
    );
  }
}
