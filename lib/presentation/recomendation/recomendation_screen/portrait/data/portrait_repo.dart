import 'dart:convert';

import '../../../../../core/db/hive_db.dart';
import '../../../../../core/models/portrait/portrait_test_definitions.dart';
import '../../../../../core/models/portrait/portrait_test_result_model.dart';

class PortraitRepo {
  static const _tag = HiveDBTags.portraitTestResults;

  Future<List<PortraitTestResultModel>> getResults() async {
    try {
      return (await HiveDB.getBox(_tag))
          .map((e) => PortraitTestResultModel.fromJson(jsonDecode(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> updateResults(List<PortraitTestResultModel> results) async {
    await HiveDB.deleteBox(_tag);
    for (var item in results) {
      HiveDB.setBox(item.toJson(), _tag);
    }
  }

  Future<void> addResult(PortraitTestResultModel result) async {
    final results = await getResults();
    // A test can be redone (result overwritten), matched by testId.
    results.removeWhere((r) => r.testId == result.testId);
    results.add(result);
    await updateResults(results);
  }

  // Dev-only: force-fills all 12 numbered tests + the bonus with a plausible
  // dominant ('A' throughout) and backdated completedAt timestamps, so the
  // 24h cadence gate is already satisfied — lets the finale (and every
  // library-card state) be tested without waiting real days. Gated behind
  // kDebugMode at the call site (Settings screen), same as the other
  // "🧪 ... (temp)" dev buttons.
  Future<void> debugForceFillAll() async {
    final now = DateTime.now();
    final results = <PortraitTestResultModel>[];
    final all = [...kPortraitNumberedOrder, PortraitTestId.bonusChronotype];
    for (var i = 0; i < all.length; i++) {
      final def = portraitTestDefinitions[all[i]]!;
      results.add(PortraitTestResultModel(
        testId: all[i].name,
        answers: List.filled(def.questions.length, 0),
        dominantKeys: const ['A'],
        completedAt: now.subtract(Duration(hours: (all.length - i) * 25)),
      ));
    }
    await updateResults(results);
  }

  // Dev-only: wipes all "Мой портрет" results back to zero, so the
  // progressive per-test star reveal can be watched from scratch instead
  // of starting already-maxed-out from debugForceFillAll.
  Future<void> debugClearAll() async {
    await updateResults(const []);
  }

  // Dev-only: completes exactly the next not-yet-done numbered test (dev
  // button call = one +1 to progress), bypassing the 24h cadence gate
  // entirely by writing straight to storage — the real UI's per-test
  // waiting period would otherwise make watching each of the 12 star-group
  // reveals live take 12 real days.
  Future<void> debugCompleteNextTest() async {
    final results = await getResults();
    final doneIds = results.map((r) => r.testId).toSet();
    PortraitTestId? next;
    for (final id in kPortraitNumberedOrder) {
      if (!doneIds.contains(id.name)) {
        next = id;
        break;
      }
    }
    next ??= doneIds.contains(PortraitTestId.bonusChronotype.name) ? null : PortraitTestId.bonusChronotype;
    if (next == null) return; // everything already done
    final def = portraitTestDefinitions[next]!;
    results.add(PortraitTestResultModel(
      testId: next.name,
      answers: List.filled(def.questions.length, 0),
      dominantKeys: const ['A'],
      completedAt: DateTime.now().subtract(const Duration(hours: 25)),
    ));
    await updateResults(results);
  }
}
