import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get/get.dart';
import 'package:riva_psy/providers/language_provider.dart';
import 'language_model.dart';

part 'event.dart';

part 'state.dart';

part 'bloc.freezed.dart';

class LanguagesBloc extends Bloc<LanguagesEvent, LanguagesState> {
  LanguagesBloc() : super(const LanguagesState.initial(locales: [], selected: null)) {

    on<LanguagesEvent>((events, emit) async {
      events.map(select: _select, fetch:  _fetch

    );
  });

}

  LanguageModel? _selected;
  final List<LanguageModel> _languages = [
    LanguageModel(name: 'Русский', code: 'ru'),
    LanguageModel(name: 'Español', code: 'es'),
    LanguageModel(name: 'English', code: 'en'),
  ];

  _fetch (_Fetch value) async {
    final locale = EasyLocalization.of(value.context)?.currentLocale;
    if(locale == null) return;
    _selected = _languages.firstWhereOrNull((element) => element.code == locale.languageCode);

    emit(LanguagesState.initial(locales: _languages, selected: _selected));

  }

  _select (_Select value) async {
    _selected = _languages.firstWhere((element) => element.code == value.languageModel.code);
    final locale = Locale(_selected!.code, _selected!.code.toUpperCase());
    EasyLocalization.of(value.context)?.setLocale(locale);
    value.context.read<LanguageProvider>().changeLocale(locale);

    emit(LanguagesState.initial(locales: _languages, selected: _selected));

  }
}
