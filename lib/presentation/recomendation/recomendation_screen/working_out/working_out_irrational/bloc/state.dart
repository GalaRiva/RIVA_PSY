
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/models/spent_record_model.dart';

import '../../../../../../../core/models/day_event_model.dart';

class WorkingOutIrrationalState {
  final bool loading;
  final WorkingOutIrrationalState? prevState;
  final WorkingOutIrrationalStage stage;
  final DayEventModel? dayEventModel;
  final SpentRecordModel? spendRecordModel;

  WorkingOutIrrationalState({this.loading = false, this.dayEventModel, this.spendRecordModel, required this.stage, this.prevState});

  WorkingOutIrrationalState copyWith(
      {WorkingOutIrrationalState? prevState,
      WorkingOutIrrationalStage? stage,
      DayEventModel? dayEventModel}) {
    return WorkingOutIrrationalState(
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

enum WorkingOutIrrationalStage {
  initialStage,
  alternative,
  challengeDo,
  challengeThought,
  cognitiveDistortions,
  alternativeDo,
  alternativeThought,
  recordDo,
  recordThought,
  gratitude,
  relax
}
