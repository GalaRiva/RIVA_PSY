import 'emotion_model.dart';

class PlaceModel {
  final String place;
  final List<EmotionModel> emotions;
  int emotionMax = 0;
  // Stable, language-independent identifier mirroring EventModel.key —
  // null for custom places the user typed themselves.
  final String? placeKey;

  PlaceModel(this.place, this.emotions, {this.placeKey});

  String get identity => placeKey ?? place;
}