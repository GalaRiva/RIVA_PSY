import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:riva_psy/core/user_data/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'datasource_service.dart';

class NegativeEmotionTabs {
  static final tabs = <NegativeEmotionTab>[];

  static const String TABS_KEY = 'TABS_KEY';
  static const String TABS_IMAGES_KEY = 'TABS_IMAGES';

  // Same pattern as NegativeEmotionsModel._localizedField for
  // Text_Recommendation: Tabs docs carry the Russian group name in `name`
  // plus optional name_{lang} for the other locales. Falls back to the
  // Russian field whenever a translation is missing.
  static String _localizedTabName(Map<String, dynamic> data, String langCode) {
    if (langCode != 'ru') {
      final value = data['name_$langCode'];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return (data['name'] ?? '').toString();
  }

  static Future getTabs (BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String appDocPath = (await getApplicationDocumentsDirectory()).path;
    try {
      try {
        await FirebaseFirestore.instance.runTransaction((transaction) {
          return Future(() {});
        });
      }catch (_) {}
      final tabsImagesColl =  FirebaseFirestore.instance.collection(
          'Tabs_Images');
      final tabsColl = FirebaseFirestore.instance.collection('Tabs');
        final _tabs = await tabsColl.orderBy('order').get();
        final _tabsImages = await tabsImagesColl.orderBy('order').get();



        await prefs.setString(TABS_KEY,
            '{${_tabs.docs.map((e) => e.data().toString()).toString()}}'
                .replaceAll('(', '')
                .replaceAll(')', ''));
        await prefs.setString(TABS_IMAGES_KEY,
            '{${_tabsImages.docs.map((e) => e.data().toString()).toString()}}'
                .replaceAll('(', '')
                .replaceAll(')', ''));

        final langCode = context.locale.languageCode;
        for (int i = 0; i < _tabs.docs.length; i++) {
          final data = _tabs.docs[i].data();

          var imagePath = appDocPath + '/' + 'tabs_images/${data['tag']}.svg';

          if (DataSourceService.dataSourceIsRemote()) {
            imagePath = _tabsImages.docs[i].data()['url'];
          }

          tabs.add(NegativeEmotionTab(i, _localizedTabName(data, langCode), imagePath, data['tag']));
        }


    }catch(_) {
      debugPrint('get tabs error ' + _.toString());
      final String? tabsStr = prefs.getString(NegativeEmotionTabs.TABS_KEY);
      final String? tabsImagesStr = prefs.getString(NegativeEmotionTabs.TABS_IMAGES_KEY);
      if(tabsStr != null && tabsImagesStr != null){
        Map tabsDocs = json.decode(tabsStr);
        Map imagesDocs = json.decode(tabsImagesStr);

        for (int i = 0; i < tabsDocs.length; i++) {
          final data = tabsDocs[i].data();

          var imagePath = appDocPath + '/' + 'tabs_images/${data['tag']}.svg';

          if (DataSourceService.dataSourceIsRemote()) {
            imagePath = imagesDocs[i].data()['url'];
          }

          tabs.add(NegativeEmotionTab(i, _localizedTabName(data, context.locale.languageCode), imagePath, data['tag']));
        }
      }
      else {
        var errorMessage = 'unexpected_error_check_connection'.tr();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          errorMessage,
          style: TextStyle(color: Colors.red),
        )));
      }
    }

}

}

class NegativeEmotionTab {
  final int tabIndex;
  final String title;
  final String tag;
  final String imagePath;

  NegativeEmotionTab(this.tabIndex, this.title, this.imagePath, this.tag);
}

