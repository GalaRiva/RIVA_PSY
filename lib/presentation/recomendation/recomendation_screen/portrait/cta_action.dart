enum CtaActionType {
  energyMatrix,
  socialBattery,
  desiresScreen,
  challengeThought,
  challengeDo,
  happinessInFocus,
  audioTrack,
}

// One value per dominant-result CTA. audioTrack is the only variant that
// carries data (which of the 7 "Портрет" tracks to open) and the only one
// CtaActionRouter never tariff-gates — see PROJECT_CONTEXT.md §62 finding 3:
// free tests 1-6 may point at a track physically hosted inside the paywalled
// "Обретение" module, so audio CTAs open a standalone player instead of
// navigating into that module at all.
class CtaAction {
  final CtaActionType type;
  final String? trackId;

  const CtaAction._(this.type, [this.trackId]);

  static const energyMatrix = CtaAction._(CtaActionType.energyMatrix);
  static const socialBattery = CtaAction._(CtaActionType.socialBattery);
  static const desiresScreen = CtaAction._(CtaActionType.desiresScreen);
  static const challengeThought = CtaAction._(CtaActionType.challengeThought);
  static const challengeDo = CtaAction._(CtaActionType.challengeDo);
  static const happinessInFocus = CtaAction._(CtaActionType.happinessInFocus);

  static CtaAction audioTrack(String trackId) =>
      CtaAction._(CtaActionType.audioTrack, trackId);
}
