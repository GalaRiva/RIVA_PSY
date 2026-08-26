import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/models/tariff_model.dart';
import 'package:riva_psy/core/services/notifications/awesome_notification_service.dart';
import 'package:riva_psy/core/services/notifications/flutter_local_notification_service.dart';
import 'package:riva_psy/core/user_data/user.dart';
import 'package:riva_psy/core/utils/shared_prefs.dart';
import 'package:riva_psy/presentation/initial_setup/splash_screen/repository.dart';
import '../../../core/models/audio/audio.dart';
import '../../../core/services/datasource_service.dart';
import '../../../core/services/workmanager/workmanager_service.dart';
import '../../recomendation/recomendation_screen/controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/negative_emotion_tabs.dart';
import '../../../core/services/firebase/firebase_cloud_storage.dart';
import '../sign_in/domain/usecases/get_and_set_remote_data_locally.dart';

class K1Controller extends GetxController {
  bool loading = false;
  bool wasInit = false;
  // Was bumped to 6 for a diagnostic round (ruling out "shows too briefly
  // to notice" as the explanation for "this screen never shows" reports)
  // — confirmed unrelated (the real cause was the GetBuilder loading
  // indicator, since removed from k1_screen.dart), and 6s read as slow.
  // This fires *after* all real init work below has already finished — it
  // was pure padding on top of the actual (network-dependent) wait, not
  // guarding anything except the sub-frame race described where it's set
  // below. 400ms is comfortably more than that one frame needs.
  int msToNewPage = 400;

  final _repo = K1Repo();

  Timer timer(BuildContext context) =>
      Timer(Duration(milliseconds: msToNewPage), () async {

            if (CurrentUser.user.passwordEnable &&
                CurrentUser.user.password!.isNotEmpty) {
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.enterPasswordScreen, (route) => false);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.main, (route) => false);
            }


      });

  void initialization(BuildContext context) async {
    AppRoutes.notificationScreenIsInitial = false;
    try {
      WorkManagerService().initService();

      if(await FirebaseAuth.instance.authStateChanges().first != null) {
        await CurrentUser.init();
        print('[TARIFF-DIAG] after CurrentUser.init(): cached tariff = "${CurrentUser.user.currentTariff?.name}"');
        try {
          if(CurrentUser.repo.userId().isNotEmpty)
            await GetAndSetRemoteDataLocally().getAndSetRemoteDataLocally(CurrentUser.repo.userId());

        } catch (e, st) {
          print('[TARIFF-DIAG] EXCEPTION during splash remote sync: $e\n$st');
        }
        print('[TARIFF-DIAG] after splash sync: final tariff = "${CurrentUser.user.currentTariff?.name}" tariffIsOrion=${CurrentUser.tariffIsOrion()}');
      }

      if (wasInit != true) {

        wasInit = true;
        await someProcess();
        DataSourceService.getDataSourceType();

        final controller = Get.put(K70Controller());
        await NegativeEmotionTabs.getTabs(context);
        await controller.initNegativeEmotions();
        if (!DataSourceService.dataSourceIsRemote()) {
          var collectionAudio =
              await FirebaseFirestore.instance.collection('Audio').get();
          var collectionImages =
              await FirebaseFirestore.instance.collection('Tabs_Images').get();

          final IMAGE_KEY = 'images_data';
          final AUDIO_KEY = 'audio_data';

          loading = true;
          update();
          _downloadingFiles([collectionAudio, collectionImages], SharedPrefs.sharedPreferences,
              [AUDIO_KEY, IMAGE_KEY], onError: () {
            loading = false;
            // Was 0 — Timer(Duration(seconds: 0), ...) fires on the next
            // event-loop tick, racing Flutter's first frame paint instead
            // of guaranteeing it. A trivial widget tree usually wins that
            // race (which is why the bisected single-Container test on
            // this screen painted fine); the real Stack/Image/GetBuilder
            // tree needs more layout work and consistently lost it,
            // producing exactly the reported "blank flash" — same race
            // class as the earlier stale-controller splash bug, different
            // trigger. A small non-zero delay guarantees at least one
            // real frame gets presented before navigating away.
            msToNewPage = 400;
            DataSourceService.setRemoteDataSource();
            timer(context);
          }).then((value) {
            loading = false;
            // Was 0 — Timer(Duration(seconds: 0), ...) fires on the next
            // event-loop tick, racing Flutter's first frame paint instead
            // of guaranteeing it. A trivial widget tree usually wins that
            // race (which is why the bisected single-Container test on
            // this screen painted fine); the real Stack/Image/GetBuilder
            // tree needs more layout work and consistently lost it,
            // producing exactly the reported "blank flash" — same race
            // class as the earlier stale-controller splash bug, different
            // trigger. A small non-zero delay guarantees at least one
            // real frame gets presented before navigating away.
            msToNewPage = 400;
            timer(context);
          });
        } else {
          loading = false;
          timer(context);
        }
      } else timer(context);
    } catch (_) {
      print('error $_');
      timer(context);
    }
  }

  final storage = CloudStorageService();

  Future _downloadingFiles(
      List<QuerySnapshot<Map<String, dynamic>>> collections,
      SharedPreferences prefs,
      List<String> prefsKeys,
      {VoidCallback? onError}) async {
    try {
      final _downloadedFiles = await _repo.getEvent();

      for (int i = 0; i < collections.length; i++) {
        if ((prefs.getString(prefsKeys[i]) ?? '') !=
            collections[i].docs.asMap().toString()) {
          print(prefsKeys[i] + "KEY");
          bool hasError = false;

          for (var item in collections[i].docs) {
            if (!hasError) {
              final audio = Audio.fromJson(item.data());
              bool wasDownloaded = false;
              for (var downloadedFile in _downloadedFiles) {
                if (downloadedFile.compareWithDifferent(audio)) {
                  wasDownloaded = true;
                  break;
                }
              }
              if (!wasDownloaded) {
                final String path = audio.fileName.trim() +
                    '.' +
                    audio.format.trim();
                await storage.downloadFile(() {
                  print('error downloading in $path');
                  hasError = true;
                  DataSourceService.setRemoteDataSource();
                }, () async {
                  print(path + ' was downloaded');
                  _downloadedFiles.add(audio);
                  await _repo.updateEvent(_downloadedFiles);
                }, audio.folder, path);
              }
            }
          }

          if (!hasError) {
            await prefs.setString(
                prefsKeys[i], collections[i].docs.asMap().toString());
          }
        }
      }
    } catch (error) {
      print(error);
      onError!();
    }
  }

  Future someProcess() async {
    // for something in debug
  }
}
