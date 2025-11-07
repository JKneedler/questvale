enum QuestCreateStates {
  notCreating,
  creating,
  createdSuccess,
  createdFailed,
}

class SelectQuestState {
  final int selectedQuestZoneIndex;
  final QuestCreateStates questCreateState;

  const SelectQuestState({
    this.selectedQuestZoneIndex = -1,
    this.questCreateState = QuestCreateStates.notCreating,
  });

  SelectQuestState copyWith({
    int? selectedQuestZoneIndex,
    QuestCreateStates? questCreateState,
  }) {
    return SelectQuestState(
      selectedQuestZoneIndex:
          selectedQuestZoneIndex ?? this.selectedQuestZoneIndex,
      questCreateState: questCreateState ?? this.questCreateState,
    );
  }
}
