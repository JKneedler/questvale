import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/gear_up_page.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/quest_board_cubit.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/quest_board_state.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/select_quest/select_quest_page.dart';
import 'package:questvale/cubits/world_tab/world_cubit.dart';
import 'package:questvale/widgets/qv_animated_transition.dart';
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

class QuestBoardView extends StatelessWidget {
  const QuestBoardView({super.key});

  Widget _getQuestBoardPage(
      BuildContext context, QuestBoardState questBoardState) {
    if (questBoardState.questBoardState ==
        QuestBoardStates.selectingQuestZone) {
      return SelectQuestPage(key: const ValueKey('selectQuestPage'));
    }
    if (questBoardState.questBoardState == QuestBoardStates.gearingUp ||
        questBoardState.questBoardState ==
            QuestBoardStates.questCreationFailed) {
      return GearUpPage(key: const ValueKey('gearUpPage'));
    }
    return Container();
  }

  QvAnimatedTransitionType _getTransitionType(
      QuestBoardStates questBoardState) {
    if (questBoardState == QuestBoardStates.selectingQuestZone) {
      return QvAnimatedTransitionType.slideRight;
    }
    return QvAnimatedTransitionType.slideLeft;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuestBoardCubit, QuestBoardState>(
      listenWhen: (prev, next) =>
          next.questBoardState == QuestBoardStates.questCreated,
      listener: (context, questBoardState) {
        context.read<WorldCubit>().onQuestCreated();
        // The Quest Board is now a TownVisitSheet, not a full page — once
        // WorldCubit has swapped WorldView's underlying display over to
        // QuestEncounterPage, close the sheet so that page is actually
        // visible instead of sitting hidden underneath it.
        Navigator.of(context).pop();
      },
      builder: (context, questBoardState) {
        return QvAnimatedTransition(
          duration: const Duration(milliseconds: 200),
          type: _getTransitionType(questBoardState.questBoardState),
          child: _getQuestBoardPage(context, questBoardState),
        );
      },
    );
  }
}
