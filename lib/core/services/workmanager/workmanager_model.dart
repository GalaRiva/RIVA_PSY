class WorkManagerModel {
  final int hour;
  final int minute;
  final String pillName;
   Duration duration;
   final DateTime end;

  WorkManagerModel(this.hour, this.minute, this.pillName, this.duration, this.end);

  factory WorkManagerModel.fromJson(Map<String, dynamic> json) {
    return WorkManagerModel(
      json['hour'] as int,
      json['minute'] as int,
      (json['pillName'] ?? '') as String,
      json['duration'] ?? Duration.zero,
      json['end'] ?? DateTime.now()
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'hour': hour,
      'minute': minute,
      'pillName': pillName,
      'duration' : duration,      'end' : end
    };
    return data;
  }
}