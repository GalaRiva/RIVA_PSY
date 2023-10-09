import 'package:firebase_storage/firebase_storage.dart';

class Audio {
  final String fileName;
  final String folder;
  final String name;
  final String format;
  final String tab;
  final List<String>? emotions;

  Audio(this.fileName, this.folder, this.name, this.format, this.tab, this.emotions);

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(
        json.toString().contains('fileName') ? json['fileName'] : json['name'],
        json.toString().contains('folder') ?json['folder'] : 'audio',
        json.toString().contains('name') ?json['name'] : '',
        json.toString().contains('format') ?json['format'] : 'mp3',
        json.toString().contains('tab') ? json['tab'] : '',
        json.toString().contains('emotions') ? (json['emotions'] as String? ?? '').split(', ') : []

    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['fileName'] = this.fileName;
    json['folder'] = this.folder;
    json['name'] = this.name;
    json['format'] = this.format;
    json['tab'] = this.tab;
    json['emotions'] = this.emotions;
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