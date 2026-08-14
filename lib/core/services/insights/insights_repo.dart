import 'dart:convert';

import '../../db/hive_db.dart';
import '../../models/insight_model.dart';

class InsightsRepo {
  static const _tag = HiveDBTags.insights;

  Future<List<InsightModel>> getAll() async {
    final raw = await HiveDB.getBox(_tag);
    return raw.map((e) => InsightModel.fromJson(jsonDecode(e))).toList();
  }

  Future<void> add(InsightModel insight) async {
    final all = await getAll();
    all.add(insight);
    await _save(all);
  }

  Future<void> markRead(String id) => _update(id, (i) => i.copyWith(isRead: true));

  Future<void> setFeedback(String id, String feedback) =>
      _update(id, (i) => i.copyWith(feedback: feedback));

  Future<void> _update(String id, InsightModel Function(InsightModel) transform) async {
    final all = await getAll();
    for (int i = 0; i < all.length; i++) {
      if (all[i].id == id) {
        all[i] = transform(all[i]);
        break;
      }
    }
    await _save(all);
  }

  Future<void> _save(List<InsightModel> list) async {
    await HiveDB.deleteBox(_tag);
    for (var item in list) {
      await HiveDB.setBox(item.toJson(), _tag);
    }
  }
}
