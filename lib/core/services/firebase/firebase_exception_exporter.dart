import 'dart:async';

import 'package:timezone/standalone.dart' as tz;

import '../../db/firebase_firestore/data/repository.dart';
import '../../user_data/user.dart';

class FirebaseExceptionExporter {
  static final _repo = FireStoreRepositoryImpl();
  static bool _canSendError = true;
  static const int _delayBetweenReportsInSec = 10;

  static Future exportException(dynamic exception) async {
    try {
      if (_canSendError) {
        final now = DateTime.now().toUtc();
        final user = CurrentUser.repo
            .userId()
            .isEmpty
            ? 'anon'
            : CurrentUser.repo.userId();
        await _repo.createPostInFirestoreDatabase(
            selectedCollection: 'Exceptions',
            docPath: '$user ${now.toIso8601String()}',
            content: {
              'exception': exception.toString(),
              'time_utc': now.toIso8601String()
            });
        _canSendError = false;
        Timer(Duration(seconds: _delayBetweenReportsInSec), () async {
          _canSendError = true;
        });
      }
    } catch (_) {
      print (_.toString());
    }
  }
}
