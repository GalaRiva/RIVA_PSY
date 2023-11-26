class SuperQuestState {
  final int dayQuantityAfterStart;
  final bool confirm;
  final SuperQuestStage stage;
  final SuperQuestState? prevState;
  SuperQuestState({this.prevState, required this.dayQuantityAfterStart, required this.confirm, required this.stage});

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    return false;
  }

  SuperQuestState copyWith({int? dayQuantity, bool? confirm}) {
    return SuperQuestState(dayQuantityAfterStart: dayQuantity?? dayQuantityAfterStart, confirm: confirm ?? this.confirm, stage: stage, prevState: prevState);
  }

}

enum SuperQuestStage {
  start,
  middle,
  end,
}