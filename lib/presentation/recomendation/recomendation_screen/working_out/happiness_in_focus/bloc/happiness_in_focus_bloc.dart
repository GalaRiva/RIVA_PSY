import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riva_psy/core/models/day_event_model.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/bloc/happiness_in_focus_state.dart';

import '../../../../../../core/models/event_model.dart';
import '../../../../../main/path/first_thougths_screen/repository.dart';

class HappinessInFocusCubit extends Cubit< HappinessInFocusState>{
  final thoughtController = TextEditingController();

  HappinessInFocusCubit() : super(HappinessInFocusState(prevState: null, dayEventModel: null, stage: HappinessInFocusStage.InitialHappinessInFocusState)) {
   _repo.getEvent().then((value) {
     return positiveDayEventModels = value
         .where((element) =>
     element.emotionInDayEvent == EmotionInDayEvent.POSITIVE || (element.whatEmotion?.first ?? EventModel('', '')).name.contains(' +'))
         .toList()
         .length;
   });
   emit(state);
  }
  final _repo = K38Repo();
  DayEventModel? _dayEventModel;
  set setDayEventModel (DayEventModel dayEventModel) => _dayEventModel = dayEventModel;
  DayEventModel? get dayEventModel => _dayEventModel;

  int positiveDayEventModels = 0;
  int _todayWorkingOut = 0;
  int get todayWorkingOut => _todayWorkingOut;

  Future saveDayEventModel ({Function? whenSave}) async {
      final events =[... await _repo.getEvent()];
      events.add(_dayEventModel!);
      await _repo.updateEvent(events);
      positiveDayEventModels++;
      _todayWorkingOut++;
      whenSave?.call();
      emit(state.copyWith(prevState: null, stage: HappinessInFocusStage.StartHappinessInFocusState));
  }

  void goToPrevState(BuildContext context) {
    if (state.prevState == null) {
      Navigator.pop(context);
    } else {
      if (state.dayEventModel != state.prevState?.dayEventModel) {
        _dayEventModel = state.prevState?.dayEventModel;
      }
      emit(state.prevState!);
    }
  }
  void goToNextState(HappinessInFocusStage stage) {
    emit(HappinessInFocusState(
        stage: stage,
        prevState: state,
        dayEventModel: _dayEventModel,));
  }

}