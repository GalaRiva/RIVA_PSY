// One row of GuidedJournals/{topic_id} in Firestore, already resolved to
// the current locale — see GuidedJournalsRepository for the raw shape
// (title/questions/insight are {ru,en,es} maps, linked_audio_{lang} are
// per-language specific-track paths, linked_audio_tab is the group
// fallback tag) and the audio-selection priority.
class GuidedJournalTopic {
  final String id;
  final String title;
  final List<String> questions;
  final String insight;
  final String? linkedAudioTab;
  final String? linkedAudioPath; // already the current-locale value
  final String? scientificBasis;
  final String? imageUrl;

  const GuidedJournalTopic({
    required this.id,
    required this.title,
    required this.questions,
    required this.insight,
    this.linkedAudioTab,
    this.linkedAudioPath,
    this.scientificBasis,
    this.imageUrl,
  });
}
