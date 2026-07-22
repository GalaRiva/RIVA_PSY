import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/connectors/v1.dart';

class LanguageProvider extends Bloc<LangEvent, LangState> {
  Locale? _currentLocale;

  LanguageProvider() : super(LangState());

  void changeLocale (Locale locale) {
    _currentLocale = locale;
    emit(state);
  }
}

class LangState {

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    return false;
  }
}

class LangEvent {

}