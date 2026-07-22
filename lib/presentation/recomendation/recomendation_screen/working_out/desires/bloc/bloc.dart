import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/desires/widgets/wishes_detail_dialog.dart';

import '../../../../../../core/db/hive_db.dart';
import '../../../../../../core/models/desire/desire.dart';

part 'event.dart';

part 'state.dart';

part 'bloc.freezed.dart';

class DesiresBloc extends Bloc<DesiresEvent, DesiresState> {
  DesiresBloc() : super(const DesiresState.initial()) {
    _getDesires().then((value) {
      if (value.isNotEmpty) {
        _desires = value;
      }
    });
    on<DesiresEvent>((events, emit) async {
      events.map(
          start: _start,
          getDetails: _getDetails,
          saveDesiresText: _saveDesiresText,
          saveDetailsText: _saveDetailsText,
          executeNewDesire: _executeNewDesire,
          saveDesire: _saveDesire,
          execute: _execute,
          cancel: _cancel,
          goToReport: _goToReport);
    });
  }

  final _desiresController = TextEditingController();
  final _desiresDetailController = TextEditingController();

  _start(_Start value) {
    emit(DesiresState.createDesire1(desires: _desiresController));
  }

  _goToReport(_GoToReport value) {
    _desires.sort((a, b) => a.dateOfExecution.compareTo(b.dateOfExecution));
    emit(DesiresState.initialIsNotEmpty(
        desires: _desires,
        completed: _desires.where((e) => e.completed).toList(),
        inProcess: _desires
            .where((e) =>
                e.dateOfExecution.isAfter(DateTime.now()) && !e.completed)
            .toList(),
        expired: _desires
            .where((e) =>
                e.dateOfExecution.isBefore(DateTime.now()) && !e.completed)
            .toList()));
  }

  _cancel(_Cancel value) {
    _desiresDetailController.text = '';
    _desiresController.text = '';
    emit(DesiresState.initial());
  }

  List<Desire> _desires = [];
  int _detailIndex = 0;

  _getDetails(_GetDetails value) {
    showDialog(
        context: value.context,
        builder: (context) {
          return WishesDetailDialog(
            index: _detailIndex,
            onNext: () {
              Navigator.pop(context);
              add(DesiresEvent.getDetails(value.context));
            },
            onStart: () {
              add(DesiresEvent.start());
              Navigator.pop(context);
            },
          );
        });
    _detailIndex = _detailIndex > 3 ? 0 : _detailIndex + 1;
  }

  _saveDesiresText(_SaveDesiresText value) {
    emit(DesiresState.createDesire2(details: _desiresDetailController));
  }

  _saveDetailsText(_SaveDetailsText value) {
    emit(DesiresState.createDesire3());
  }

  _executeNewDesire(_ExecuteNewDesire value) async {
    final exercise = Desire(
        simpleDesires: _desiresController.text,
        desireDetails: _desiresDetailController.text,
        dateOfExecution: value.dateTime ?? DateTime.now(),
        createdAt: DateTime.now(),
        completed: value.dateTime == null
            ? true
            : value.dateTime!.isAfter(DateTime.now())
                ? false
                : false);
    _desires.insert(0, exercise);
    _updateDesires(_desires);
    _desiresController.text = '';
    _desiresDetailController.text = '';
    add(DesiresEvent.goToReport());
  }

  _saveDesire(_SaveDesire value) async {}

  _execute(_Execute value) async {
    final index = _desires.indexOf(value.desire);
    _desires.removeAt(index);
    _desires.insert(index, value.desire.copyWith(completed: true));
    _updateDesires(_desires);
    add(DesiresEvent.goToReport());
  }

  Future<List<Desire>> _getDesires() async {
    var listToReturn = (await HiveDB.getBox(HiveDBTags.desires))
        .map((e) => Desire.fromJson(jsonDecode(e)))
        .toList();
    if (listToReturn.isEmpty) {
      listToReturn = [];
    }
    return listToReturn;
  }

  Future<void> _updateDesires(List<Desire> events) async {
    // TODO: implement updateTasks
    await HiveDB.openBox(HiveDBTags.desires);
    await HiveDB.deleteBox(HiveDBTags.desires);
    events.sort((d1, d2) => d1.dateOfExecution.compareTo(d2.dateOfExecution));
    for (var item in events) {
      HiveDB.setBox(item.toJson(), HiveDBTags.desires);
    }
  }
}
