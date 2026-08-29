import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/data/repository.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/models/spent_record_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  int workingOutEventsLength() => _spentRecordModels.length;

  int dontWorkingOutEventsLength() => _dontWorkingOutEvents.length;

  int allNegativeDayEventsLength() => _dayEvents.length;

  // Date-range-aware counterparts for the "Новое решение!" progress counter
  // — the plain versions above ignore dateStart/dateEnd entirely, so the
  // period picker on the Альтернативы screen had no effect on the numbers
  // it sits right next to. Mirrors the filtering already done in
  // getSpentRecordModels() below.
  int workingOutEventsLengthInRange() => _spentRecordModels
      .where((e) => e.dayEventModel.date!.dateInRange(dateStart, dateEnd))
      .length;

  int allNegativeDayEventsLengthInRange() => _dayEvents
      .where((e) => e.date!.dateInRange(dateStart, dateEnd))
      .length;

  SpentRecordModel lastSpentRecordModel() => _spentRecordModels.last;

  int get spentRecordsToday => _spentRecordModels.where((element) => element.date.difference(DateTime.now()).inHours.abs() < 24).length;

  var dateStart =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

  var dateEnd = DateTime.now().add(Duration(days: 7 - DateTime.now().weekday));

  TabController? tabController;
  int currentTab = 0;

  late  List<DayEventModel> _dayEvents;
  late List<DayEventModel> _dontWorkingOutEvents;
  late List<SpentRecordModel> _spentRecordModels;
  DayEventModel? selectedDayEventModel;

  final _repo = WorkingOutRepo();

  void fillSpendRecordModel(
      {String? whyThisThoughts,
      String? whyThisDo,
      String? alternativeThoughts,
      String? alternativeDo,
      List<String>? cognitiveDistortions}) {
    _currentSpentRecordModel = _currentSpentRecordModel == null
        ? SpentRecordModel(
            dayEventModel: selectedDayEventModel!,
            whyThisThoughts: whyThisThoughts ?? '',
            alternativeThoughts: alternativeThoughts ?? '',
            whyThisDo: whyThisDo ?? '',
            alternativeDo: alternativeDo ?? '', date: DateTime.now(),
            cognitiveDistortions: cognitiveDistortions)
        : _currentSpentRecordModel!.copyWith(
            whyThisDo: whyThisDo,
            whyThisThoughts: whyThisThoughts,
            alternativeDo: alternativeDo,
            alternativeThoughts: alternativeThoughts,
            cognitiveDistortions: cognitiveDistortions);
  }

  void init() async {
    _dayEvents = (await _repo.getDayEvent()).where((element) => element.emotionInDayEvent! == EmotionInDayEvent.NEGATIVE).toList();
    debugPrint('${_dayEvents.map((e) => e.whatIDo).toList()}');
    print('dayEvents' + _dayEvents.length.toString());
    _dontWorkingOutEvents = _dayEvents
        .where((element) =>
            !element.workingOut)
        .toList();
    _spentRecordModels = await _repo.getEvent();
    if (existMoreDontWorkingOutEvents()) {
      selectedDayEventModel = _dontWorkingOutEvents.last;
      if (_spentRecordModels.isNotEmpty &&
          _spentRecordModels.map((e) => e.dayEventModel).toList().contains(
              selectedDayEventModel)) {
        _currentSpentRecordModel = _spentRecordModels
            .where((element) => element.dayEventModel == selectedDayEventModel)
            .first;
      }
    }
    emit(WorkingOutIrrationalState(
        stage: WorkingOutIrrationalStage.initialStage, loading: false));
  }

  Future updateDayEvents({nextState  = true}) async {
    if(selectedDayEventModel == null) {
      await SharedPreferences.getInstance().then((prefs) async {
        var dateInStr = prefs.getString('firstSpendRecord');
        if (dateInStr == null) {
          dateInStr = DateTime.now().toIso8601String();
          await prefs.setString('firstSpendRecord', dateInStr);
        }
        if (nextState) {
          if (DateTime.parse(dateInStr).difference(DateTime.now()).inDays > 7) {
            goToNextState(WorkingOutIrrationalStage.alternative);
          } else {
            goToNextState(WorkingOutIrrationalStage.gratitude);
          }
        }
      });
      return;
    }

    // Capture the event actually being completed *before* it gets
    // reassigned below to whatever's next (or null, if this was the last
    // one) — the save-and-advance block used to run against the
    // already-reassigned value, so finishing the last outstanding event
    // made it null and silently skipped saving _currentSpentRecordModel
    // and skipped both goToNextState calls (alternative/gratitude),
    // leaving only the caller's hardcoded fallback to initialStage.
    final justCompletedDayEvent = selectedDayEventModel!;
    if(nextState) {
      _dayEvents = await _repo.getDayEvent();
      final index = _dayEvents.indexOf(justCompletedDayEvent);
      print('dayEventIndex - $index');
      if(index >= 0) {
        _dayEvents.removeAt(index);
        _dayEvents.insert(
            index, justCompletedDayEvent.copyWith(workingOut: true));
        _repo.updateDayEventEvent(_dayEvents);
        _dontWorkingOutEvents.removeLast();
      }
    }
    {
      final index = _spentRecordModels
          .map((e) => e.dayEventModel)
          .toList()
          .indexOf(justCompletedDayEvent);
      print('spendModelIndex - $index');
      if (index >= 0) {
        _spentRecordModels.removeAt(index);
        _spentRecordModels.insert(index, _currentSpentRecordModel!);
      } else {
        _spentRecordModels.add(_currentSpentRecordModel!);
      }
      _repo.updateEvent(_spentRecordModels);
      if (nextState) _currentSpentRecordModel = null;
      await SharedPreferences.getInstance().then((prefs) async {
        var dateInStr = prefs.getString('firstSpendRecord');
        if (dateInStr == null) {
          dateInStr = DateTime.now().toIso8601String();
          await prefs.setString('firstSpendRecord', dateInStr);
        }
        if (nextState) {
          if (DateTime.parse(dateInStr).difference(DateTime.now()).inDays > 7) {
            goToNextState(WorkingOutIrrationalStage.alternative);
          } else {
            goToNextState(WorkingOutIrrationalStage.gratitude);
          }
        }
      });
    }
    selectedDayEventModel =
      existMoreDontWorkingOutEvents() ? _dontWorkingOutEvents.last : null;
  }

  Future<List<SpentRecordModel>> getSpentRecordModels() async {
    final listForReturn = <SpentRecordModel>[];
    for (var event in _spentRecordModels) {
      if (event.dayEventModel.date!.dateInRange(dateStart, dateEnd))
        listForReturn.add(event);
    }
    print(listForReturn.length);
    return listForReturn;
  }

  void redoSpentRecordModel () {
    _currentSpentRecordModel = lastSpentRecordModel();
    selectedDayEventModel = _currentSpentRecordModel!.dayEventModel;
    goToNextState(WorkingOutIrrationalStage.recordThought);

  }

  void goToPrevState(BuildContext context) {
    if (state.prevState == null) {
      Navigator.pop(context);
    } else {
      if (state.spendRecordModel != state.prevState?.spendRecordModel &&
          state.spendRecordModel == lastSpentRecordModel()) {
        _currentSpentRecordModel = state.prevState?.spendRecordModel;
      }
      emit(state.prevState!);
    }
  }

  void updatePage() {
    emit(state);

  }

  void goToNextState(WorkingOutIrrationalStage stage) {
    emit(WorkingOutIrrationalState(
        stage: stage,
        prevState: state,
        dayEventModel: selectedDayEventModel,
        spendRecordModel: _currentSpentRecordModel));
  }
}
