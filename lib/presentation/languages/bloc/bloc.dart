import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get/get.dart';
import 'package:riva_psy/providers/language_provider.dart';
import '../../../core/services/negative_emotion_tabs.dart';
import '../../recomendation/recomendation_screen/controller.dart';
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

  static const _countryCodes = {'ru': 'RU', 'en': 'US', 'es': 'ES'};

  _select (_Select value) async {
    _selected = _languages.firstWhere((element) => element.code == value.languageModel.code);
    final locale = Locale(_selected!.code, _countryCodes[_selected!.code] ?? _selected!.code.toUpperCase());
    await EasyLocalization.of(value.context)?.setLocale(locale);
    value.context.read<LanguageProvider>().changeLocale(locale);

    // "Справиться с эмоцией" tab labels (NegativeEmotionTabs.tabs) and
    // track titles (NegativeEmotionsModel, held on K70Controller) are both
    // built once and cached for the rest of the app session — neither
    // re-reads on its own when the language changes here, so they'd stay
    // frozen in whatever language was active when first built until a
    // full app restart. Force both to rebuild against the locale just set
    // above (context.locale is already updated at this point).
    if (value.context.mounted) {
      await NegativeEmotionTabs.getTabs(value.context);
    }
    if (Get.isRegistered<K70Controller>()) {
      final k70 = Get.find<K70Controller>();
      k70.negativeEmotionsModel = null;
      await k70.initNegativeEmotions();
      k70.update();
    }

    emit(LanguagesState.initial(locales: _languages, selected: _selected));

  }
}
