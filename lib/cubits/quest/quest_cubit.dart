import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/quest/quest_state.dart';

class QuestCubit extends Cubit<QuestState> {
  QuestCubit({required bool showQuestView})
      : super(QuestState(showQuestView: showQuestView));

  void showQuestView() {
    emit(state.copyWith(showQuestView: true));
  }

  void hideQuestView() {
    emit(state.copyWith(showQuestView: false));
  }
}
