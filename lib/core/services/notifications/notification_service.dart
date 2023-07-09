
import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/presentation/settings/settings_pills/models/pill_model.dart';

import '../workmanager/workmanager_model.dart';

abstract class NotificationService {
  Future showNotification (WorkManagerModel workManagerModel);
  void notificationActionStream (BuildContext context);
}