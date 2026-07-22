
import 'package:flutter/material.dart';
import 'package:riva_psy/presentation/settings/settings_pills/models/pill_model.dart';

import '../workmanager/workmanager_model.dart';

abstract class NotificationService {
  Future showNotification (WorkManagerModel workManagerModel, Duration dur);
  void navigator (BuildContext context, Function otherNavigationFunc);
}