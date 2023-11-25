import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:path_provider/path_provider.dart';

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
      text: 'Злость',
    ),
    Tab(
      text: 'Паника',
    ),
    Tab(
      text: 'Страх',
    ),
    Tab(
      text: 'Грусть',
    ),
    Tab(
      text: 'Обида',
    ),
    Tab(
      text: 'Неуверенность',
    ),
    Tab(
      text: 'Отвращение',
    ),
    Tab(
      text: 'Вина',
    ),
    Tab(
      text: 'Лень',
    ),
    Tab(
      text: 'Одиночество',
    ),
    Tab(
      text: 'Потерянность',
    ),
  ];

  List<Widget> tabBodies = [];
  List<double> tabHeights = [];

  Future<List<AudioCardModel>?> _audioAssets(String tab) async {
    try {
      var collection =
          await FirebaseFirestore.instance.collection('Audio').where('tab', isEqualTo: tab).get();
      final audios = <AudioCardModel>[];
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;
      for (var item in collection.docs) {
        final audio = Audio.fromJson(item.data());
        try {

          String filePath = appDocPath +
              '/' +
              '${audio.folder}/${audio.fileName}.${audio.format}';
          if (DataSourceService.dataSourceIsRemote()) {
            filePath = 'http://95.181.164.171/' + audio.fileName + '.' + audio.format;
          }
          if (audio.tab == tab)
            audios.add(AudioCardModel(audio.name, filePath));
        } catch (_) {
          print('error load ${ 'http://95.181.164.171/' + audio.fileName + '.' + audio.format}');
          print (_);
        }
      }
      return sortRussianAlphabetically(audios);
    } catch (_) {
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

  Future<List<SelectButtonWidget>?> _funButtons(String tab) async {
    try {
      var collection = await FirebaseFirestore.instance
          .collection('Text_Recommendation')
          .get();
      final buttons = <SelectButtonWidget>[];
      for (var item in collection.docs) {
        if (item.data()['tab'] == tab)
          buttons.add(SelectButtonWidget(
            title: item.data()['title'],
            content: item.data()['content'],
            height: double.parse(item.data()['height'].toString()) ?? 160,
          ));
      }
      return buttons;
    } catch (_) {
      return [];
    }
  }

  Future<List<Widget>> getTabBodies() async {
    final list = <Widget>[];
    tabHeights = [];
    tabs = NegativeEmotionTabs.tabs.map((e) => Tab(text: e.title)).toList();
    for (var item in NegativeEmotionTabs.tabs) {
      final audios =  await _audioAssets(item.tag);
      if (item.tag == 'panic') controller.panicTab = item.tabIndex;
      final tab = NegativeTab(
          funAudioAssets: audios,
          funTitleText:
              'Каждое упражнение заканчивайте глубоким вдохом и выдохом через рот 3 раза. Почувствуйте, как изменилось ощущение в руках, ногах, груди',
          funButtons: await _funButtons(item.tag),
          funTitleImage: item.imagePath);
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
