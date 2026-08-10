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
  // document. Only 'es' exists for now; add more _<langCode> fields the same
  // way if/when other languages get their own recordings.
  final String? fileNameEs;
  final String? nameEs;

  Audio(this.fileName, this.folder, this.name, this.format, this.tab, this.emotions, {this.fileNameEs, this.nameEs});

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
    );
  }

  // Localized display name/file, following the same `_localizedField`
  // fallback-to-Russian shape used by NegativeEmotionsModel/NegativeEmotionTabs.
  String localizedName(String langCode) =>
      langCode == 'es' && (nameEs ?? '').trim().isNotEmpty ? nameEs! : name;
  String localizedFileName(String langCode) =>
      langCode == 'es' && (fileNameEs ?? '').trim().isNotEmpty ? fileNameEs! : fileName;

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