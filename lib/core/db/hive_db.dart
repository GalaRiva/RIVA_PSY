import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path;

import '../services/firebase/firebase_exception_exporter.dart';

class HiveDB {
  static Directory? _dir;
  static String? _pathDataForTransfer;

  static Future initDB() async {
    if (_dir == null || _pathDataForTransfer == null) {
      _dir = await path.getApplicationDocumentsDirectory();
      _pathDataForTransfer = '${_dir!.path}/dataForTransfer.json';
    }
    Hive.init(_dir!.path);
  }

  static Future<File> setHiveDBInFile() async {
    String dataForTransfer = '';
    for (int i = 0; i < HiveDBTags.allTagsForTransfer.length; i++) {
      final item = HiveDBTags.allTagsForTransfer[i];
      final boxData = await getBox(item);
      var listToReturn = boxData.map((e) => jsonDecode(e).toString()).toList();
      if (listToReturn.isNotEmpty) {
        String _endPoint = ',';
        if(i == HiveDBTags.allTagsForTransfer.length - 1) _endPoint = '';
        dataForTransfer += ('\"$item\":' + '[' + boxData.join(',').toString() + ']$_endPoint');
      }
    }
    dataForTransfer = '{$dataForTransfer}';
    print(dataForTransfer);
    return await _createFileToTransfer(dataForTransfer);
  }

  static Future<File> _createFileToTransfer(String content) async {
    final file = File(_pathDataForTransfer!);
    await file.create(recursive: true);
    // Gzipped instead of plain text — backup history only grows, and diary
    // JSON compresses well (lots of repeated key names). getHiveDBFromFile
    // below still falls back to reading a file as plain JSON, so backups
    // made before this change keep restoring correctly.
    await file.writeAsBytes(gzip.encode(utf8.encode(content)));

    return file;
  }

  static Future getHiveDBFromFile(String path) async {
    try {
      final file = File(path);
      final bytes = await file.readAsBytes();
      String contents;
      try {
        contents = utf8.decode(gzip.decode(bytes));
      } catch (_) {
        // Not gzip — an older, pre-compression backup. Read as plain JSON.
        contents = utf8.decode(bytes);
      }
      Map<String, dynamic> data = jsonDecode(contents);
      for (var item in HiveDBTags.allTagsForTransfer) {
        await openBox(item);
        List<dynamic>? maps = data[item];
        await deleteBox(item);
        if (maps != null)
          for (final e in maps) {
            await setBox(e, item);
          }
      }
    } catch (_) {
      throw(_);
      FirebaseExceptionExporter.exportException(_);
    }
  }

  static Future deleteBox(String section) async {
    await Hive.box(section).clear();
  }

  static Future openBox(String section) async {
    await Hive.openBox(section);
  }

  static Future<List> getBox(String section) async {
    await openBox(section);
    List<dynamic> list = [];
    for (int i = 0; i < Hive.box(section).length; i++) {
      final item = Hive.box(section).getAt(i);
      if(item != null)
      list.add(Hive.box(section).getAt(i));
    }
    return list;
  }

  // in cycle
  static Future setBox(dynamic value, String section) async {
    await openBox(section);
    Hive.box(section).add(jsonEncode(value));
  }
}

class HiveDBTags {
  static const allTagsForTransfer = [
    events,
    place,
    persona,
    emotions1,
    emotions2,
    emotions3,
    emotions4,
    bodyParts,
    dayEvents,
    pills,
    spentRecords,
    desires,
    insights,
    guidedJournalAnswers
  ];
  static const events = 'events';
  static const desires = 'desires';
  static const place = 'place';
  static const persona = 'persona';
  static const emotions1 = 'emotions1';
  static const emotions2 = 'emotions2';
  static const emotions3 = 'emotions3';
  static const emotions4 = 'emotions4';
  static const bodyParts = 'bodyParts';
  static const notCompleteDayEvents = 'notCompleteDayEvents';
  static const dayEvents = 'dayEvents';
  static const tariff = 'tariff';
  static const emotionalState = 'emotionalState';
  static const audio = 'audio';
  static const pills = 'pills';
  static const spentRecords = 'spentRecords';
  static const insights = 'insights';
  static const guidedJournalAnswers = 'guidedJournalAnswers';
}
