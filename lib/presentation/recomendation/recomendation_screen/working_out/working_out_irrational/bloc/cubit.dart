import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/data/repository.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/models/spent_record_model.dart';
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

  SpentRecordModel lastSpentRecordModel() => _spentRecordModels.last;

  int spentRecordsToday = 0;

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
    _dayEvents = (await _repo.getDayEvent()).where((element) => element.emotionInDayEvent! == EmotionInDayEvent.NEGATIVE).toList();
    print('dayEvents' + _dayEvents.length.toString());
    _dontWorkingOutEvents = _dayEvents
        .where((element) =>
            !element.workingOut)
        .toList();
    _spentRecordModels = await _repo.getEvent();
    if (existMoreDontWorkingOutEvents())
      selectedDayEventModel = _dontWorkingOutEvents.last;
    emit(WorkingOutIrrationalState(
        stage: WorkingOutIrrationalStage.initialStage, loading: false));
  }

  Future updateDayEvents() async {
    if(_spentRecordModels.isNotEmpty && _currentSpentRecordModel == lastSpentRecordModel()) {
      _spentRecordModels = _spentRecordModels.where((element) => element.dayEventModel == _currentSpentRecordModel!.dayEventModel).toList()..last = _currentSpentRecordModel!;
    } else {
      _dayEvents = _dayEvents
          .where((element) => element == selectedDayEventModel)
          .toList()
          ..last = selectedDayEventModel!.copyWith(workingOut: true);
      _repo.updateDayEventEvent(_dayEvents);
      _dontWorkingOutEvents.removeLast();
      spentRecordsToday++;
    }
    selectedDayEventModel =
      existMoreDontWorkingOutEvents() ? _dontWorkingOutEvents.last : null;
    if(_spentRecordModels.isEmpty || _spentRecordModels.isNotEmpty && _currentSpentRecordModel != lastSpentRecordModel())
      _spentRecordModels.add(_currentSpentRecordModel!);
      _repo.updateEvent(_spentRecordModels);
    _currentSpentRecordModel = null;
    SharedPreferences.getInstance().then((prefs) async {
      var dateInStr = prefs.getString('firstSpendRecord');
      if(dateInStr == null) {
        dateInStr = DateTime.now().toIso8601String();
        await prefs.setString('firstSpendRecord', dateInStr);
      }
      if(DateTime.parse(dateInStr).difference(DateTime.now()).inDays > 7){
        goToNextState(WorkingOutIrrationalStage.alternative);
      } else {
        goToNextState(WorkingOutIrrationalStage.gratitude);

      }
    }
      );
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
