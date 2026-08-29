// Standard CBT distortion taxonomy (Beck/Burns "Feeling Good") — not a
// proprietary test, no licensing involved. Keys are stable slugs used both
// as translation-key suffixes (see cognitive_distortions_page.dart) and as
// the persisted values in SpentRecordModel.cognitiveDistortions, so they
// must never change once shipped.
class CognitiveDistortionOption {
  final String key;
  // Non-null only for the two "jumping to conclusions" subtypes — renders a
  // shared group label above them, matching the source table's structure,
  // while still keeping both individually selectable.
  final String? groupKey;

  const CognitiveDistortionOption(this.key, {this.groupKey});

  static const all = <CognitiveDistortionOption>[
    CognitiveDistortionOption('all_or_nothing_thinking'),
    CognitiveDistortionOption('overgeneralization'),
    CognitiveDistortionOption('mental_filter'),
    CognitiveDistortionOption('disqualifying_positive'),
    CognitiveDistortionOption('mind_reading', groupKey: 'jumping_to_conclusions'),
    CognitiveDistortionOption('fortune_telling', groupKey: 'jumping_to_conclusions'),
    CognitiveDistortionOption('catastrophizing'),
    CognitiveDistortionOption('emotional_reasoning'),
    CognitiveDistortionOption('should_statements'),
    CognitiveDistortionOption('labeling'),
    CognitiveDistortionOption('personalization'),
  ];
}
