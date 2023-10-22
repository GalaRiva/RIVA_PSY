import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/data/repository.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/models/spent_record_model.dart';

import '../../../../../../../core/models/day_event_model.dart';
import '../../../../../../../core/user_data/user.dart';
import 'state.dart';

class WorkingOutIrrationalCubit extends Cubit<WorkingOutIrrationalState> {
  WorkingOutIrrationalCubit()
      : super(WorkingOutIrrationalState(
            stage: WorkingOutIrrationalStage.initialStage, loading: true));

  SpentRecordModel? _currentSpentRecordModel;

  bool get showContent => CurrentUser.tariffIsOrion();

  bool existMoreDontWorkingOutEvents() => _dontWorkingOutEvents.isNotEmpty;
  TabController? tabController;
  int currentTab = 0;

  late final List<DayEventModel> _dayEvents;
  late final List<DayEventModel> _dontWorkingOutEvents;

  DayEventModel? selectedDayEventModel;

  final _repo = WorkingOutRepo();

  void fillSpendRecordModel(
      {String? whyThisThoughts,
      String? whyThisDo,
      String? alternativeThoughts,
      String? alternativeDo}) {
    _currentSpentRecordModel = _currentSpentRecordModel == null
        ? SpentRecordModel(
            dayEventModel: selectedDayEventModel!,
            whyThisThoughts: whyThisThoughts ?? '',
            alternativeThoughts: alternativeThoughts ?? '',
            whyThisDo: whyThisDo ?? '',
            alternativeDo: alternativeDo ?? '')
        : _currentSpentRecordModel!.copyWith(
            whyThisDo: whyThisDo,
            whyThisThoughts: whyThisThoughts,
            alternativeDo: alternativeDo,
            alternativeThoughts: alternativeThoughts);
  }

  void init() async {
    _dayEvents = (await _repo.getDayEvent());
    print('dayEvents' + _dayEvents.length.toString());
    _dontWorkingOutEvents = _dayEvents
        .where((element) =>
            !element.workingOut &&
            element.emotionInDayEvent! == EmotionInDayEvent.NEGATIVE)
        .toList();
    if (existMoreDontWorkingOutEvents())
      selectedDayEventModel = _dontWorkingOutEvents.last;
    emit(WorkingOutIrrationalState(
        stage: WorkingOutIrrationalStage.initialStage, loading: false));
  }

  void updateDayEvents() {
    _dayEvents
        .where((element) => element == selectedDayEventModel)
        .toList().last = selectedDayEventModel!.copyWith(workingOut: true);
    _repo.updateDayEventEvent(_dayEvents);
    _dontWorkingOutEvents.removeLast();
    selectedDayEventModel =
        existMoreDontWorkingOutEvents() ? _dontWorkingOutEvents.last : null;
    _currentSpentRecordModel = null;
    goToNextState(WorkingOutIrrationalStage.alternative);
  }

  void goToPrevState(BuildContext context) {
    if (state.prevState == null) {
      Navigator.pop(context);
    } else {
      emit(state.prevState!);
    }
  }

  void goToNextState(WorkingOutIrrationalStage stage) {
    emit(WorkingOutIrrationalState(stage: stage, prevState: state, dayEventModel: selectedDayEventModel, spendRecordModel: _currentSpentRecordModel));
  }
}
