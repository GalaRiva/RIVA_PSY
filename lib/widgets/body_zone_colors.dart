import 'package:flutter/material.dart';

/// User-specified body-zone colors (2026-08-07): "голова и лицо — голубой,
/// горло — синий, грудная клетка — бордовый, плечи и руки — красный,
/// живот — зеленый, ноги — желтый, спина — фиолетовый." Keyed by
/// BodyPartsModel.key (see what_body_parts_screen/repository.dart).
const Map<String, Color> bodyZoneColors = {
  'head_and_face': Color(0xFF4FC3F7), // голубой
  'throat': Color(0xFF2962FF), // синий
  'chest': Color(0xFF800020), // бордовый
  'shoulders_and_arms': Color(0xFFE53935), // красный
  'stomach': Color(0xFF43A047), // зеленый
  'legs': Color(0xFFFDD835), // желтый
  'back': Color(0xFF30D5C8), // бирюзовый
};

Color bodyZoneColor(String? key, Color fallback) =>
    bodyZoneColors[key] ?? fallback;
