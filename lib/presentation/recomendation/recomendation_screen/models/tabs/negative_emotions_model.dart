import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/models/audio/audio.dart';
import '../../../../../core/models/audio/audio_card_model.dart';
import '../../../../../core/services/datasource_service.dart';
import '../../../../../core/services/negative_emotion_tabs.dart';
import '../../controller.dart';
import '../../widgets/select_botton_widget.dart';
import '../../widgets/tab_widget.dart';
import 'negative_tab_model.dart';

class NegativeEmotionsModel {
  final K70Controller controller;

  NegativeEmotionsModel(this.controller);

  List<Widget> tabs = [
    Tab(
      text: 'wrath'.tr(),
    ),
    Tab(
      text: 'panic'.tr(),
    ),
    Tab(
      text: 'fear2'.tr(),
    ),
    Tab(
      text: 'sorrow'.tr(),
    ),
    Tab(
      text: 'resentment'.tr(),
    ),
    Tab(
      text: 'uncertainty'.tr(),
    ),
    Tab(
      text: 'disgust'.tr(),
    ),
    Tab(
      text: 'guilt'.tr(),
    ),
    Tab(
      text: 'laziness'.tr(),
    ),
    Tab(
      text: 'loneliness'.tr(),
    ),
    Tab(
      text: 'lostness'.tr(),
    ),
  ];

  List<Widget> tabBodies = [];
  List<double> tabHeights = [];

  Future<List<AudioCardModel>?> _audioAssets(String tab) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final langCode = (prefs.getString('locale') ?? 'ru_RU').split('_').first;
      var collection =
          await FirebaseFirestore.instance.collection('Audio').where('tab', isEqualTo: tab).get();
      final audios = <AudioCardModel>[];
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;
      for (var item in collection.docs) {
        final audio = Audio.fromJson(item.data());
        try {
          final fileName = audio.localizedFileName(langCode);
          String filePath = appDocPath +
              '/' +
              '${audio.folder}/${fileName}.${audio.format}';
          if (DataSourceService.dataSourceIsRemote()) {
            filePath = 'https://pub-cd14ca249f1e4d4fbfb07ca99a7efe6d.r2.dev/audio/' + fileName + '.' + audio.format;
          }
          if (audio.tab == tab)
            audios.add(AudioCardModel(audio.localizedName(langCode), filePath,
                ruTitle: audio.name, knownDuration: audio.localizedDuration(langCode)));
        } catch (_) {
          print('error load ${ 'https://pub-cd14ca249f1e4d4fbfb07ca99a7efe6d.r2.dev/audio/' + audio.fileName + '.' + audio.format}');
          print (_);
        }
      }
      return sortRussianAlphabetically(audios);
    } catch (_) {
      debugPrint('[AUDIO-DIAG] _audioAssets("$tab") failed: $_');
      return [];
    }
  }

  List<AudioCardModel> sortRussianAlphabetically(List<AudioCardModel> strings) {
    final russianAlphabet = 'абвгдежзийклмнопрстуфхцчшщъыьэюя';

    // Создаем функцию-ключ для сортировки: индекс буквы в русском алфавите
    List<int> sortKey(String string) {
      return string.toLowerCase().split('').map((char) {
        return russianAlphabet.indexOf(char);
      }).toList();
    }

    // Сортируем список строк
    strings.sort((a, b) => compareLists(sortKey(a.title), sortKey(b.title)));

    return strings;
  }

// Функция для сравнения двух списков
  int compareLists(List<int> list1, List<int> list2) {
    for (int i = 0; i < list1.length && i < list2.length; i++) {
      if (list1[i] < list2[i]) {
        return -1;
      } else if (list1[i] > list2[i]) {
        return 1;
      }
    }

    return list1.length.compareTo(list2.length);
  }

  // Text_Recommendation docs carry the Russian text in title/content (the
  // original, always-present fields) plus optional title_{lang}/content_{lang}
  // added for the other supported locales. Falls back to the Russian field
  // whenever a translation is missing for a given position, rather than
  // showing blank text.
  String _localizedField(
      Map<String, dynamic> data, String field, String langCode) {
    if (langCode != 'ru') {
      final value = data['${field}_$langCode'];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return (data[field] ?? '').toString();
  }

  Future<List<SelectButtonWidget>?> _funButtons(String tab) async {
    try {
      // Prefer a server round-trip over the default get(), which can be
      // satisfied from cloud_firestore's local persistence cache — a
      // device that queried this collection before today's title_en/
      // title_es write would otherwise keep serving that pre-translation
      // snapshot indefinitely for an unfiltered whole-collection get().
      // Falls back to the (possibly stale) cache if genuinely offline,
      // rather than showing no recommendations at all.
      QuerySnapshot<Map<String, dynamic>> collection;
      try {
        collection = await FirebaseFirestore.instance
            .collection('Text_Recommendation')
            .get(const GetOptions(source: Source.server));
      } catch (_) {
        collection = await FirebaseFirestore.instance
            .collection('Text_Recommendation')
            .get();
      }
      final buttons = <SelectButtonWidget>[];
      final prefs = await SharedPreferences.getInstance();
      final langCode = (prefs.getString('locale') ?? 'ru_RU').split('_').first;
      print('[TEXTREC-DIAG] tab="$tab" langCode="$langCode" totalDocsFetched=${collection.docs.length}');
      final docs = collection.docs.where((item) => item.data()['tab'] == tab).toList();
      docs.sort((a, b) {
        final orderA = a.data()['order'];
        final orderB = b.data()['order'];
        if (orderA is num && orderB is num) return orderA.compareTo(orderB);
        return 0;
      });
      for (var item in docs) {
        final data = item.data();
        final title = _localizedField(data, 'title', langCode);
        print('[TEXTREC-DIAG]   doc="${item.id}" hasTitleField="${data.containsKey('title_$langCode')}" -> title="$title"');
        buttons.add(SelectButtonWidget(
          title: title,
          content: _localizedField(data, 'content', langCode),
          height: double.parse(data['height'].toString()) ?? 160,
        ));
      }
      return buttons;
    } catch (_) {
      debugPrint('[TEXTREC-DIAG] _funButtons("$tab") failed: $_');
      return [];
    }
  }

  Future<List<Widget>> getTabBodies() async {
    final list = <Widget>[];
    tabHeights = [];

    tabs = NegativeEmotionTabs.tabs
        .map((e) => Tab(
              child: Text(
                e.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ))
        .toList();
    // Bundled replacements for tags whose Firestore-sourced icon isn't set —
    // takes priority over item.imagePath so these three always show the
    // supplied artwork regardless of what's configured server-side.
    const localImageOverrides = {
      'wrath': ImageConstant.recommendationsWrath,
      'resentment': ImageConstant.recommendationsResentment,
      'sorrow': ImageConstant.recommendationsSorrow,
    };
    for (var item in NegativeEmotionTabs.tabs) {
      final audios =  await _audioAssets(item.tag);
      if (item.tag == 'panic') controller.panicTab = item.tabIndex;
      final tab = NegativeTab(
          funAudioAssets: audios,
          funTitleText: 'breathing_relaxation_instruction'.tr(),
          funButtons: await _funButtons(item.tag),
          funTitleImage: localImageOverrides[item.tag] ?? item.imagePath);
      final tabHeight = ((audios?.length ?? 0) * (getVerticalSize(65) + 30)) + 200;
      tabHeights.add(tabHeight);
      list.add(TabWidget(
        tab: tab,
        controller: controller,
        height: tabHeight,
        isStandardCheck: item.tag == 'panic' ? false : true,
      ));
    }
    tabBodies = list;
    return tabBodies;
  }
}
