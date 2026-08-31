import 'package:firebase_storage/firebase_storage.dart';

class Audio {
  final String fileName;
  final String folder;
  final String name;
  final String format;
  final String tab;
  final List<String>? emotions;
  // Per-locale overrides, same `<field>_<langCode>` convention already used
  // elsewhere in this app for Firestore text (e.g. Tabs.name_es,
  // Text_Recommendation.title_es) — absent on every pre-existing (Russian)
  // document. Add more _<langCode> fields the same way if/when other
  // languages get their own recordings.
  final String? fileNameEs;
  final String? nameEs;
  final String? fileNameEn;
  final String? nameEn;
  // Precomputed once (ffprobe, run against the R2-hosted file) and stored
  // here instead of asked for over the network on every app open — see
  // PROJECT_CONTEXT.md: the negative-emotion tabs used to probe every
  // track's duration live via a sequential setUrl() per card, which is
  // what actually made those tabs feel frozen on a cold start.
  final int? durationMs;
  final int? durationMsEn;
  final int? durationMsEs;

  Audio(this.fileName, this.folder, this.name, this.format, this.tab, this.emotions,
      {this.fileNameEs, this.nameEs, this.fileNameEn, this.nameEn, this.durationMs, this.durationMsEn, this.durationMsEs});

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(
        json.toString().contains('fileName') ? json['fileName'] : json['name'],
        json.toString().contains('folder') ?json['folder'] : 'audio',
        json.toString().contains('name') ?json['name'] : '',
        json.toString().contains('format') ?json['format'] : 'mp3',
        json.toString().contains('tab') ? json['tab'] : '',
        json.toString().contains('emotions') ? (json['emotions'] as String? ?? '').split(', ') : [],
        fileNameEs: json['fileName_es'] as String?,
        nameEs: json['name_es'] as String?,
        fileNameEn: json['fileName_en'] as String?,
        nameEn: json['name_en'] as String?,
        durationMs: (json['duration_ms'] as num?)?.toInt(),
        durationMsEn: (json['duration_ms_en'] as num?)?.toInt(),
        durationMsEs: (json['duration_ms_es'] as num?)?.toInt(),
    );
  }

  // Localized display name/file, following the same `_localizedField`
  // fallback-to-Russian shape used by NegativeEmotionsModel/NegativeEmotionTabs.
  String localizedName(String langCode) {
    if (langCode == 'es' && (nameEs ?? '').trim().isNotEmpty) return nameEs!;
    if (langCode == 'en' && (nameEn ?? '').trim().isNotEmpty) return nameEn!;
    return name;
  }
  String localizedFileName(String langCode) {
    if (langCode == 'es' && (fileNameEs ?? '').trim().isNotEmpty) return fileNameEs!;
    if (langCode == 'en' && (fileNameEn ?? '').trim().isNotEmpty) return fileNameEn!;
    return fileName;
  }

  Duration? localizedDuration(String langCode) {
    final ms = langCode == 'es'
        ? (durationMsEs ?? durationMs)
        : langCode == 'en'
            ? (durationMsEn ?? durationMs)
            : durationMs;
    return ms == null ? null : Duration(milliseconds: ms);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['fileName'] = this.fileName;
    json['folder'] = this.folder;
    json['name'] = this.name;
    json['format'] = this.format;
    json['tab'] = this.tab;
    json['emotions'] = this.emotions;
    json['fileName_es'] = this.fileNameEs;
    json['name_es'] = this.nameEs;
    json['fileName_en'] = this.fileNameEn;
    json['name_en'] = this.nameEn;
    return json;
  }



  bool compareWithDifferent (Audio other) {
    if(this.name != other.name) return false;
    if(this.fileName != other.fileName) return false;
    if(this.folder != other.folder) return false;
    if(this.format != other.folder) return false;
    if(this.tab != other.tab) return false;
    if(this.emotions != other.emotions) return false;
    return true;
  }
}