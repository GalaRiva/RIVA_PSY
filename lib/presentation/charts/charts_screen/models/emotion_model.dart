import 'package:flutter/material.dart';

class EmotionModel {
  int quantity;
  final String name;
  final Color color;
  // Stable, language-independent identifier mirroring EventModel.key —
  // null for custom emotions and for category-bucket EmotionModels whose
  // `name` already holds a stable key string (e.g. 'positive_emotions').
  final String? key;

  EmotionModel(this.quantity, this.name, this.color, {this.key});

  String get identity => key ?? name;
}