class SelectQuestState {
  final int selectedQuestZoneIndex;

  const SelectQuestState({
    this.selectedQuestZoneIndex = -1,
  });

  SelectQuestState copyWith({
    int? selectedQuestZoneIndex,
  }) {
    return SelectQuestState(
      selectedQuestZoneIndex:
          selectedQuestZoneIndex ?? this.selectedQuestZoneIndex,
    );
  }
}
