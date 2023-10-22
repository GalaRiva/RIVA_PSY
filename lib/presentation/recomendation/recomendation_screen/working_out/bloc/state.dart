import '../../../../../core/models/day_event_model.dart';

class WorkingOutState {
  final WorkingOutState? prevState;

  WorkingOutState({ this.prevState});

  WorkingOutState copyWith(
      {WorkingOutState? prevState,}) {
    return WorkingOutState(
        prevState: prevState ?? this.prevState,);
  }
}