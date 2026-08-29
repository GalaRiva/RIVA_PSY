import '../models/guided_journal_topic.dart';

enum GuidedJournalStage { library, question, insight }

class GuidedJournalsState {
  final bool loading;
  final GuidedJournalStage stage;
  final List<GuidedJournalTopic> topics;
  final GuidedJournalTopic? selectedTopic;
  final int questionIndex;
  final List<String> answers;
  final String? audioUrl;
  final bool resolvingAudio;

  const GuidedJournalsState({
    this.loading = true,
    this.stage = GuidedJournalStage.library,
    this.topics = const [],
    this.selectedTopic,
    this.questionIndex = 0,
    this.answers = const [],
    this.audioUrl,
    this.resolvingAudio = false,
  });

  GuidedJournalsState copyWith({
    bool? loading,
    GuidedJournalStage? stage,
    List<GuidedJournalTopic>? topics,
    GuidedJournalTopic? selectedTopic,
    int? questionIndex,
    List<String>? answers,
    String? audioUrl,
    bool? resolvingAudio,
  }) {
    return GuidedJournalsState(
      loading: loading ?? this.loading,
      stage: stage ?? this.stage,
      topics: topics ?? this.topics,
      selectedTopic: selectedTopic ?? this.selectedTopic,
      questionIndex: questionIndex ?? this.questionIndex,
      answers: answers ?? this.answers,
      audioUrl: audioUrl ?? this.audioUrl,
      resolvingAudio: resolvingAudio ?? this.resolvingAudio,
    );
  }

  // Explicit reset back to the library — copyWith's `?? this.x` can't
  // express "clear this field", so returning to stage 1 needs a fresh
  // instance instead of a copyWith call.
  factory GuidedJournalsState.library(List<GuidedJournalTopic> topics) =>
      GuidedJournalsState(loading: false, topics: topics);
}
