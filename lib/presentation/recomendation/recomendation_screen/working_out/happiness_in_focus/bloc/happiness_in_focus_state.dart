import 'package:listenmebaby71_s_application17/core/models/day_event_model.dart';

class HappinessInFocusState {
  final HappinessInFocusState? prevState;
  final DayEventModel? dayEventModel;
  final HappinessInFocusStage stage;

  HappinessInFocusState( {required this.stage, required this.prevState, required this.dayEventModel});

  HappinessInFocusState copyWith(
      {HappinessInFocusState? prevState,
        HappinessInFocusStage? stage,
        DayEventModel? dayEventModel}) {
    return HappinessInFocusState(
        stage: stage ?? this.stage,
        prevState: prevState ?? this.prevState,
        dayEventModel: dayEventModel ?? this.dayEventModel);
  }

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    return false;
  }
}

enum HappinessInFocusStage {
  InitialHappinessInFocusState,
  StartHappinessInFocusState,
  ThoughtsHappinessInFocusState,
  AfterWorkingOutHappinessInFocusState,

  WhatHappenedHappinessInFocusState,
  WhereHappenedHappinessInFocusState,
  WithWhoHappenedHappinessInFocusState,
  WhatEmotionHappenedHappinessInFocusState,
  WhatWithBodyHappinessInFocusState
}