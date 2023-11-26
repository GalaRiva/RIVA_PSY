import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/super_quest/cubit/state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuperQuestCubit extends Cubit<SuperQuestState> {
  SuperQuestCubit()
      : super(SuperQuestState(
            dayQuantityAfterStart: 0,
            confirm: false,
            stage: SuperQuestStage.start)) {
    SharedPreferences.getInstance().then((value) {
      final val = value.getString('_startDateTime');
      if (val == null || val.isEmpty) {
        _startDateTime = DateTime.now();
        value.setString('_startDateTime', _startDateTime.toIso8601String());
      } else
        _startDateTime = DateTime.parse(val);
      _confirmDays = value.getInt(
            'confirmDays',
          ) ??
          0;
      _confirm =
          _confirmDays > _startDateTime.difference(DateTime.now()).inDays;

      emit(SuperQuestState(
        stage: SuperQuestStage.start,
        dayQuantityAfterStart: _confirmDays > _startDateTime.difference(DateTime.now()).inDays ? _startDateTime.difference(DateTime.now()).inDays : _confirmDays,
        confirm: _confirm,
      ));
    });
  }

  int _confirmDays = 0;
  bool _confirm = false;
  late final DateTime _startDateTime;

  bool confirm() {
    _confirm = true;
    goToNextState(SuperQuestStage.start);
    return _confirm;
  }

  void save() async {
    if (_confirmDays <= _startDateTime.difference(DateTime.now()).inDays) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('confirmDays', _confirmDays++);
    }
    if (_confirmDays >= 3)
      goToNextState(SuperQuestStage.end);
    else
      goToNextState(SuperQuestStage.start);
  }

  void cancel() async {
    if (_confirmDays > _startDateTime.difference(DateTime.now()).inDays) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('confirmDays', _confirmDays--);
    }
    goToNextState(SuperQuestStage.start);
  }

  void completeSuperQuest() {
    SharedPreferences.getInstance().then((value) {
      value.setString('_startDateTime', '');
      value.setInt('confirmDays', 0);

      _confirm =
          _confirmDays > _startDateTime.difference(DateTime.now()).inDays;

      emit(SuperQuestState(
        stage: SuperQuestStage.start,
        dayQuantityAfterStart: _confirmDays > _startDateTime.difference(DateTime.now()).inDays ? _startDateTime.difference(DateTime.now()).inDays : _confirmDays,
        confirm: _confirm,
      ));
    });
  }

  void goToPrevState(BuildContext context) {
    if (state.prevState == null) {
      Navigator.pop(context);
    } else {
      emit(state.prevState!);
    }
  }

  void goToNextState(SuperQuestStage stage) {
    emit(SuperQuestState(
      stage: stage,
      prevState: state,
      dayQuantityAfterStart: _confirmDays > _startDateTime.difference(DateTime.now()).inDays ? _startDateTime.difference(DateTime.now()).inDays : _confirmDays,
      confirm: _confirm,
    ));
  }
}
