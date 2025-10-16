import 'package:equatable/equatable.dart';

class QuestState extends Equatable {
  final bool showQuestView;

  const QuestState({this.showQuestView = false});

  QuestState copyWith({
    bool? showQuestView,
  }) {
    return QuestState(
      showQuestView: showQuestView ?? this.showQuestView,
    );
  }

  @override
  List<Object?> get props => [showQuestView];
}
