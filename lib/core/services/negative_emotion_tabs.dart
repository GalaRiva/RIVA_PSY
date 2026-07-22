import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:listenmebaby71_s_application17/core/user_data/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'datasource_service.dart';

class NegativeEmotionTabs {
  static final tabs = <NegativeEmotionTab>[];

  static const String TABS_KEY = 'TABS_KEY';
  static const String TABS_IMAGES_KEY = 'TABS_IMAGES';

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
        final _tabs = await tabsColl.get();
        final _tabsImages = await tabsImagesColl.get();



        await prefs.setString(TABS_KEY,
            '{${_tabs.docs.map((e) => e.data().toString()).toString()}}'
                .replaceAll('(', '')
                .replaceAll(')', ''));
        await prefs.setString(TABS_IMAGES_KEY,
            '{${_tabsImages.docs.map((e) => e.data().toString()).toString()}}'
                .replaceAll('(', '')
                .replaceAll(')', ''));

        for (int i = 0; i < _tabs.docs.length; i++) {
          final data = _tabs.docs[i].data();

          var imagePath = appDocPath + '/' + 'tabs_images/${data['tag']}.svg';

          if (DataSourceService.dataSourceIsRemote()) {
            imagePath = _tabsImages.docs[i].data()['url'];
          }

          tabs.add(NegativeEmotionTab(i, data['name'], imagePath, data['tag']));
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

          tabs.add(NegativeEmotionTab(i, data['name'], imagePath, data['tag']));
        }
      }
      else {
        var errorMessage =
            'Возникла непредвиденная ошибка, проверьте подключение к интернету или запустите приложение позднее.';
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

