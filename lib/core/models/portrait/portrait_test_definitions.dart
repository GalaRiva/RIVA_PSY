import '../../../presentation/recomendation/recomendation_screen/portrait/cta_action.dart';

// 12 numbered tests + 1 bonus (no numeric slot — see PROJECT_CONTEXT.md §62
// finding 1: "Хронотип" and "Взгляд в будущее" both drafted as "Тест 12" in
// different parts of the source master-plan; resolved by giving Хронотип a
// separate non-numeric id instead of renumbering anything else).
enum PortraitTestId {
  hiddenSupports, // 1: Скрытые опоры
  wellbeingProfile, // 2: Профиль благополучия (PERMA)
  resilience, // 3: Суперспособность восстановления
  emotionalRadar, // 4: Ваш эмоциональный радар (EQ)
  growthMindset, // 5: Стиль мышления роста
  controlProfile, // 6: Способ управлять хаосом — paywall shown right after this one
  rightToPause, // 7: Право на паузу
  innerDefender, // 8: Внутренний защитник (гнев)
  trueCompass, // 9: Истинный компас (ценности, ACT)
  innerVoice, // 10: Голос внутри (самосострадание)
  attachmentStyle, // 11: Суперспособность в отношениях — requires disclaimer
  futureOutlook, // 12: Взгляд в будущее (оптимизм), last numbered test
  bonusChronotype, // bonus, no numeric slot
}

// Sequence order for numbered tests only (bonus excluded — it never gates
// on cadence or paywall the same way, see PortraitCubit).
const List<PortraitTestId> kPortraitNumberedOrder = [
  PortraitTestId.hiddenSupports,
  PortraitTestId.wellbeingProfile,
  PortraitTestId.resilience,
  PortraitTestId.emotionalRadar,
  PortraitTestId.growthMindset,
  PortraitTestId.controlProfile,
  PortraitTestId.rightToPause,
  PortraitTestId.innerDefender,
  PortraitTestId.trueCompass,
  PortraitTestId.innerVoice,
  PortraitTestId.attachmentStyle,
  PortraitTestId.futureOutlook,
];

// Tests 1-6 free, paywall shown after test 6 and when attempting to open
// test 7 — confirmed final decision, PROJECT_CONTEXT.md §62.
const int kPortraitFreeTestCount = 6;

// "Похвала за смелость" + non-clinical-disclaimer framing required in the
// result text itself (not just the intro screen) — §62.
const Set<PortraitTestId> kPortraitShadowTestIds = {
  PortraitTestId.controlProfile,
  PortraitTestId.rightToPause,
  PortraitTestId.innerDefender,
  PortraitTestId.trueCompass,
  PortraitTestId.innerVoice,
};

class PortraitOption {
  final String text;
  final String dominantKey; // 'A' | 'B' | 'C' | 'D'
  const PortraitOption(this.text, this.dominantKey);
}

class PortraitQuestion {
  final String text;
  final List<PortraitOption> options;
  const PortraitQuestion(this.text, this.options);
}

class PortraitDominantContent {
  final String label;
  final String light;
  final String shadow;
  final String ctaLabel;
  final CtaAction cta;

  const PortraitDominantContent({
    required this.label,
    required this.light,
    required this.shadow,
    required this.ctaLabel,
    required this.cta,
  });
}

class PortraitTestDefinition {
  final String title;
  final String intro;
  final List<PortraitQuestion> questions;
  final Map<String, PortraitDominantContent> dominants; // key A/B/C/D
  final bool requiresDisclaimer;

  const PortraitTestDefinition({
    required this.title,
    required this.intro,
    required this.questions,
    required this.dominants,
    this.requiresDisclaimer = false,
  });
}

// Test 11 (attachment) disclaimer — must be shown visibly on the result
// screen itself, RU only for now (EN/ES deferred with the rest of the test
// content per the approved plan). Legal/clinical wording review is an owner
// task, not a Code task — see PROJECT_CONTEXT.md §62 owner checklist.
const String kPortraitAttachmentDisclaimer = 'portrait_t11_disclaimer';

final Map<PortraitTestId, PortraitTestDefinition> portraitTestDefinitions = {
  PortraitTestId.hiddenSupports: PortraitTestDefinition(
    title: 'portrait_t1_title',
    intro: 'portrait_t1_intro',
    questions: const [
      PortraitQuestion(
        'portrait_t1_q1',
        [
          PortraitOption('portrait_t1_q1_a', 'A'),
          PortraitOption('portrait_t1_q1_b', 'B'),
          PortraitOption('portrait_t1_q1_c', 'C'),
          PortraitOption('portrait_t1_q1_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t1_q2',
        [
          PortraitOption('portrait_t1_q2_a', 'A'),
          PortraitOption('portrait_t1_q2_b', 'B'),
          PortraitOption('portrait_t1_q2_c', 'C'),
          PortraitOption('portrait_t1_q2_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t1_q3',
        [
          PortraitOption('portrait_t1_q3_a', 'A'),
          PortraitOption('portrait_t1_q3_b', 'B'),
          PortraitOption('portrait_t1_q3_c', 'C'),
          PortraitOption('portrait_t1_q3_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t1_q4',
        [
          PortraitOption('portrait_t1_q4_a', 'A'),
          PortraitOption('portrait_t1_q4_b', 'B'),
          PortraitOption('portrait_t1_q4_c', 'C'),
          PortraitOption('portrait_t1_q4_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t1_q5',
        [
          PortraitOption('portrait_t1_q5_a', 'A'),
          PortraitOption('portrait_t1_q5_b', 'B'),
          PortraitOption('portrait_t1_q5_c', 'C'),
          PortraitOption('portrait_t1_q5_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t1_q6',
        [
          PortraitOption('portrait_t1_q6_a', 'A'),
          PortraitOption('portrait_t1_q6_b', 'B'),
          PortraitOption('portrait_t1_q6_c', 'C'),
          PortraitOption('portrait_t1_q6_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t1_q7',
        [
          PortraitOption('portrait_t1_q7_a', 'A'),
          PortraitOption('portrait_t1_q7_b', 'B'),
          PortraitOption('portrait_t1_q7_c', 'C'),
          PortraitOption('portrait_t1_q7_d', 'D'),
        ],
      ),
    ],
    dominants: {
      'A': PortraitDominantContent(
        label: 'portrait_t1_dom_a_title',
        light: 'portrait_t1_dom_a_light',
        shadow: 'portrait_t1_dom_a_shadow',
        ctaLabel: 'portrait_t1_dom_a_cta',
        cta: CtaAction.energyMatrix,
      ),
      'B': PortraitDominantContent(
        label: 'portrait_t1_dom_b_title',
        light: 'portrait_t1_dom_b_light',
        shadow: 'portrait_t1_dom_b_shadow',
        ctaLabel: 'portrait_t1_dom_b_cta',
        cta: CtaAction.socialBattery,
      ),
      'C': PortraitDominantContent(
        label: 'portrait_t1_dom_c_title',
        light: 'portrait_t1_dom_c_light',
        shadow: 'portrait_t1_dom_c_shadow',
        ctaLabel: 'portrait_t1_dom_c_cta',
        cta: CtaAction.audioTrack('removing_armor'),
      ),
      'D': PortraitDominantContent(
        label: 'portrait_t1_dom_d_title',
        light: 'portrait_t1_dom_d_light',
        shadow: 'portrait_t1_dom_d_shadow',
        ctaLabel: 'portrait_t1_dom_d_cta',
        cta: CtaAction.desiresScreen,
      ),
    },
  ),

  PortraitTestId.wellbeingProfile: PortraitTestDefinition(
    title: 'portrait_t2_title',
    intro: 'portrait_t2_intro',
    questions: const [
      PortraitQuestion(
        'portrait_t2_q1',
        [
          PortraitOption('portrait_t2_q1_a', 'A'),
          PortraitOption('portrait_t2_q1_b', 'B'),
          PortraitOption('portrait_t2_q1_c', 'C'),
          PortraitOption('portrait_t2_q1_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t2_q2',
        [
          PortraitOption('portrait_t2_q2_a', 'A'),
          PortraitOption('portrait_t2_q2_b', 'B'),
          PortraitOption('portrait_t2_q2_c', 'C'),
          PortraitOption('portrait_t2_q2_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t2_q3',
        [
          PortraitOption('portrait_t2_q3_a', 'A'),
          PortraitOption('portrait_t2_q3_b', 'B'),
          PortraitOption('portrait_t2_q3_c', 'C'),
          PortraitOption('portrait_t2_q3_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t2_q4',
        [
          PortraitOption('portrait_t2_q4_a', 'A'),
          PortraitOption('portrait_t2_q4_b', 'B'),
          PortraitOption('portrait_t2_q4_c', 'C'),
          PortraitOption('portrait_t2_q4_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t2_q5',
        [
          PortraitOption('portrait_t2_q5_a', 'A'),
          PortraitOption('portrait_t2_q5_b', 'B'),
          PortraitOption('portrait_t2_q5_c', 'C'),
          PortraitOption('portrait_t2_q5_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t2_q6',
        [
          PortraitOption('portrait_t2_q6_a', 'A'),
          PortraitOption('portrait_t2_q6_b', 'B'),
          PortraitOption('portrait_t2_q6_c', 'C'),
          PortraitOption('portrait_t2_q6_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t2_q7',
        [
          PortraitOption('portrait_t2_q7_a', 'A'),
          PortraitOption('portrait_t2_q7_b', 'B'),
          PortraitOption('portrait_t2_q7_c', 'C'),
          PortraitOption('portrait_t2_q7_d', 'D'),
        ],
      ),
    ],
    dominants: {
      'A': PortraitDominantContent(
        label: 'portrait_t2_dom_a_title',
        light: 'portrait_t2_dom_a_light',
        shadow: 'portrait_t2_dom_a_shadow',
        ctaLabel: 'portrait_t2_dom_a_cta',
        cta: CtaAction.happinessInFocus,
      ),
      'B': PortraitDominantContent(
        label: 'portrait_t2_dom_b_title',
        light: 'portrait_t2_dom_b_light',
        shadow: 'portrait_t2_dom_b_shadow',
        ctaLabel: 'portrait_t2_dom_b_cta',
        cta: CtaAction.audioTrack('reactor_cooling'),
      ),
      'C': PortraitDominantContent(
        label: 'portrait_t2_dom_c_title',
        light: 'portrait_t2_dom_c_light',
        shadow: 'portrait_t2_dom_c_shadow',
        ctaLabel: 'portrait_t2_dom_c_cta',
        cta: CtaAction.socialBattery,
      ),
      'D': PortraitDominantContent(
        label: 'portrait_t2_dom_d_title',
        light: 'portrait_t2_dom_d_light',
        shadow: 'portrait_t2_dom_d_shadow',
        ctaLabel: 'portrait_t2_dom_d_cta',
        cta: CtaAction.challengeThought,
      ),
    },
  ),

  PortraitTestId.resilience: PortraitTestDefinition(
    title: 'portrait_t3_title',
    intro: 'portrait_t3_intro',
    questions: const [
      PortraitQuestion(
        'portrait_t3_q1',
        [
          PortraitOption('portrait_t3_q1_a', 'A'),
          PortraitOption('portrait_t3_q1_b', 'B'),
          PortraitOption('portrait_t3_q1_c', 'C'),
          PortraitOption('portrait_t3_q1_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t3_q2',
        [
          PortraitOption('portrait_t3_q2_a', 'A'),
          PortraitOption('portrait_t3_q2_b', 'B'),
          PortraitOption('portrait_t3_q2_c', 'C'),
          PortraitOption('portrait_t3_q2_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t3_q3',
        [
          PortraitOption('portrait_t3_q3_a', 'A'),
          PortraitOption('portrait_t3_q3_b', 'B'),
          PortraitOption('portrait_t3_q3_c', 'C'),
          PortraitOption('portrait_t3_q3_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t3_q4',
        [
          PortraitOption('portrait_t3_q4_a', 'A'),
          PortraitOption('portrait_t3_q4_b', 'B'),
          PortraitOption('portrait_t3_q4_c', 'C'),
          PortraitOption('portrait_t3_q4_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t3_q5',
        [
          PortraitOption('portrait_t3_q5_a', 'A'),
          PortraitOption('portrait_t3_q5_b', 'B'),
          PortraitOption('portrait_t3_q5_c', 'C'),
          PortraitOption('portrait_t3_q5_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t3_q6',
        [
          PortraitOption('portrait_t3_q6_a', 'A'),
          PortraitOption('portrait_t3_q6_b', 'B'),
          PortraitOption('portrait_t3_q6_c', 'C'),
          PortraitOption('portrait_t3_q6_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t3_q7',
        [
          PortraitOption('portrait_t3_q7_a', 'A'),
          PortraitOption('portrait_t3_q7_b', 'B'),
          PortraitOption('portrait_t3_q7_c', 'C'),
          PortraitOption('portrait_t3_q7_d', 'D'),
        ],
      ),
    ],
    dominants: {
      'A': PortraitDominantContent(
        label: 'portrait_t3_dom_a_title',
        light: 'portrait_t3_dom_a_light',
        shadow: 'portrait_t3_dom_a_shadow',
        ctaLabel: 'portrait_t3_dom_a_cta',
        cta: CtaAction.audioTrack('right_to_pause'),
      ),
      'B': PortraitDominantContent(
        label: 'portrait_t3_dom_b_title',
        light: 'portrait_t3_dom_b_light',
        shadow: 'portrait_t3_dom_b_shadow',
        ctaLabel: 'portrait_t3_dom_b_cta',
        cta: CtaAction.socialBattery,
      ),
      'C': PortraitDominantContent(
        label: 'portrait_t3_dom_c_title',
        light: 'portrait_t3_dom_c_light',
        shadow: 'portrait_t3_dom_c_shadow',
        // No dedicated somatic-scan screen exists yet — temporary substitute
        // per the approved plan, marked explicitly rather than invented.
        ctaLabel: 'portrait_t3_dom_c_cta',
        cta: CtaAction.audioTrack('reactor_cooling'),
      ),
      'D': PortraitDominantContent(
        label: 'portrait_t3_dom_d_title',
        light: 'portrait_t3_dom_d_light',
        shadow: 'portrait_t3_dom_d_shadow',
        ctaLabel: 'portrait_t3_dom_d_cta',
        cta: CtaAction.challengeDo,
      ),
    },
  ),

  PortraitTestId.emotionalRadar: PortraitTestDefinition(
    title: 'portrait_t4_title',
    intro: 'portrait_t4_intro',
    questions: const [
      PortraitQuestion(
        'portrait_t4_q1',
        [
          PortraitOption('portrait_t4_q1_a', 'A'),
          PortraitOption('portrait_t4_q1_b', 'B'),
          PortraitOption('portrait_t4_q1_c', 'C'),
          PortraitOption('portrait_t4_q1_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t4_q2',
        [
          PortraitOption('portrait_t4_q2_a', 'A'),
          PortraitOption('portrait_t4_q2_b', 'B'),
          PortraitOption('portrait_t4_q2_c', 'C'),
          PortraitOption('portrait_t4_q2_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t4_q3',
        [
          PortraitOption('portrait_t4_q3_a', 'A'),
          PortraitOption('portrait_t4_q3_b', 'B'),
          PortraitOption('portrait_t4_q3_c', 'C'),
          PortraitOption('portrait_t4_q3_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t4_q4',
        [
          PortraitOption('portrait_t4_q4_a', 'A'),
          PortraitOption('portrait_t4_q4_b', 'B'),
          PortraitOption('portrait_t4_q4_c', 'C'),
          PortraitOption('portrait_t4_q4_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t4_q5',
        [
          PortraitOption('portrait_t4_q5_a', 'A'),
          PortraitOption('portrait_t4_q5_b', 'B'),
          PortraitOption('portrait_t4_q5_c', 'C'),
          PortraitOption('portrait_t4_q5_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t4_q6',
        [
          PortraitOption('portrait_t4_q6_a', 'A'),
          PortraitOption('portrait_t4_q6_b', 'B'),
          PortraitOption('portrait_t4_q6_c', 'C'),
          PortraitOption('portrait_t4_q6_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t4_q7',
        [
          PortraitOption('portrait_t4_q7_a', 'A'),
          PortraitOption('portrait_t4_q7_b', 'B'),
          PortraitOption('portrait_t4_q7_c', 'C'),
          PortraitOption('portrait_t4_q7_d', 'D'),
        ],
      ),
    ],
    dominants: {
      'A': PortraitDominantContent(
        label: 'portrait_t4_dom_a_title',
        light: 'portrait_t4_dom_a_light',
        shadow: 'portrait_t4_dom_a_shadow',
        ctaLabel: 'portrait_t4_dom_a_cta',
        cta: CtaAction.desiresScreen,
      ),
      'B': PortraitDominantContent(
        label: 'portrait_t4_dom_b_title',
        light: 'portrait_t4_dom_b_light',
        shadow: 'portrait_t4_dom_b_shadow',
        ctaLabel: 'portrait_t4_dom_b_cta',
        cta: CtaAction.audioTrack('reactor_cooling'),
      ),
      'C': PortraitDominantContent(
        label: 'portrait_t4_dom_c_title',
        light: 'portrait_t4_dom_c_light',
        shadow: 'portrait_t4_dom_c_shadow',
        ctaLabel: 'portrait_t4_dom_c_cta',
        cta: CtaAction.socialBattery,
      ),
      'D': PortraitDominantContent(
        label: 'portrait_t4_dom_d_title',
        light: 'portrait_t4_dom_d_light',
        shadow: 'portrait_t4_dom_d_shadow',
        ctaLabel: 'portrait_t4_dom_d_cta',
        cta: CtaAction.challengeDo,
      ),
    },
  ),

  PortraitTestId.growthMindset: PortraitTestDefinition(
    title: 'portrait_t5_title',
    intro: 'portrait_t5_intro',
    questions: const [
      PortraitQuestion(
        'portrait_t5_q1',
        [
          PortraitOption('portrait_t5_q1_a', 'A'),
          PortraitOption('portrait_t5_q1_b', 'B'),
          PortraitOption('portrait_t5_q1_c', 'C'),
          PortraitOption('portrait_t5_q1_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t5_q2',
        [
          PortraitOption('portrait_t5_q2_a', 'A'),
          PortraitOption('portrait_t5_q2_b', 'B'),
          PortraitOption('portrait_t5_q2_c', 'C'),
          PortraitOption('portrait_t5_q2_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t5_q3',
        [
          PortraitOption('portrait_t5_q3_a', 'A'),
          PortraitOption('portrait_t5_q3_b', 'B'),
          PortraitOption('portrait_t5_q3_c', 'C'),
          PortraitOption('portrait_t5_q3_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t5_q4',
        [
          PortraitOption('portrait_t5_q4_a', 'A'),
          PortraitOption('portrait_t5_q4_b', 'B'),
          PortraitOption('portrait_t5_q4_c', 'C'),
          PortraitOption('portrait_t5_q4_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t5_q5',
        [
          PortraitOption('portrait_t5_q5_a', 'A'),
          PortraitOption('portrait_t5_q5_b', 'B'),
          PortraitOption('portrait_t5_q5_c', 'C'),
          PortraitOption('portrait_t5_q5_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t5_q6',
        [
          PortraitOption('portrait_t5_q6_a', 'A'),
          PortraitOption('portrait_t5_q6_b', 'B'),
          PortraitOption('portrait_t5_q6_c', 'C'),
          PortraitOption('portrait_t5_q6_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t5_q7',
        [
          PortraitOption('portrait_t5_q7_a', 'A'),
          PortraitOption('portrait_t5_q7_b', 'B'),
          PortraitOption('portrait_t5_q7_c', 'C'),
          PortraitOption('portrait_t5_q7_d', 'D'),
        ],
      ),
    ],
    dominants: {
      'A': PortraitDominantContent(
        label: 'portrait_t5_dom_a_title',
        light: 'portrait_t5_dom_a_light',
        shadow: 'portrait_t5_dom_a_shadow',
        ctaLabel: 'portrait_t5_dom_a_cta',
        cta: CtaAction.challengeThought,
      ),
      'B': PortraitDominantContent(
        label: 'portrait_t5_dom_b_title',
        light: 'portrait_t5_dom_b_light',
        shadow: 'portrait_t5_dom_b_shadow',
        ctaLabel: 'portrait_t5_dom_b_cta',
        cta: CtaAction.happinessInFocus,
      ),
      'C': PortraitDominantContent(
        label: 'portrait_t5_dom_c_title',
        light: 'portrait_t5_dom_c_light',
        shadow: 'portrait_t5_dom_c_shadow',
        ctaLabel: 'portrait_t5_dom_c_cta',
        cta: CtaAction.energyMatrix,
      ),
      'D': PortraitDominantContent(
        label: 'portrait_t5_dom_d_title',
        light: 'portrait_t5_dom_d_light',
        shadow: 'portrait_t5_dom_d_shadow',
        ctaLabel: 'portrait_t5_dom_d_cta',
        cta: CtaAction.audioTrack('removing_armor'),
      ),
    },
  ),

  PortraitTestId.controlProfile: PortraitTestDefinition(
    title: 'portrait_t6_title',
    intro: 'portrait_t6_intro',
    questions: const [
      PortraitQuestion(
        'portrait_t6_q1',
        [
          PortraitOption('portrait_t6_q1_a', 'A'),
          PortraitOption('portrait_t6_q1_b', 'B'),
          PortraitOption('portrait_t6_q1_c', 'C'),
          PortraitOption('portrait_t6_q1_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t6_q2',
        [
          PortraitOption('portrait_t6_q2_a', 'A'),
          PortraitOption('portrait_t6_q2_b', 'B'),
          PortraitOption('portrait_t6_q2_c', 'C'),
          PortraitOption('portrait_t6_q2_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t6_q3',
        [
          PortraitOption('portrait_t6_q3_a', 'A'),
          PortraitOption('portrait_t6_q3_b', 'B'),
          PortraitOption('portrait_t6_q3_c', 'C'),
          PortraitOption('portrait_t6_q3_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t6_q4',
        [
          PortraitOption('portrait_t6_q4_a', 'A'),
          PortraitOption('portrait_t6_q4_b', 'B'),
          PortraitOption('portrait_t6_q4_c', 'C'),
          PortraitOption('portrait_t6_q4_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t6_q5',
        [
          PortraitOption('portrait_t6_q5_a', 'A'),
          PortraitOption('portrait_t6_q5_b', 'B'),
          PortraitOption('portrait_t6_q5_c', 'C'),
          PortraitOption('portrait_t6_q5_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t6_q6',
        [
          PortraitOption('portrait_t6_q6_a', 'A'),
          PortraitOption('portrait_t6_q6_b', 'B'),
          PortraitOption('portrait_t6_q6_c', 'C'),
          PortraitOption('portrait_t6_q6_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t6_q7',
        [
          PortraitOption('portrait_t6_q7_a', 'A'),
          PortraitOption('portrait_t6_q7_b', 'B'),
          PortraitOption('portrait_t6_q7_c', 'C'),
          PortraitOption('portrait_t6_q7_d', 'D'),
        ],
      ),
    ],
    dominants: {
      'A': PortraitDominantContent(
        label: 'portrait_t6_dom_a_title',
        light: 'portrait_t6_dom_a_light',
        shadow: 'portrait_t6_dom_a_shadow',
        ctaLabel: 'portrait_t6_dom_a_cta',
        cta: CtaAction.challengeDo,
      ),
      'B': PortraitDominantContent(
        label: 'portrait_t6_dom_b_title',
        light: 'portrait_t6_dom_b_light',
        shadow: 'portrait_t6_dom_b_shadow',
        ctaLabel: 'portrait_t6_dom_b_cta',
        cta: CtaAction.audioTrack('reactor_cooling'),
      ),
      'C': PortraitDominantContent(
        label: 'portrait_t6_dom_c_title',
        light: 'portrait_t6_dom_c_light',
        shadow: 'portrait_t6_dom_c_shadow',
        ctaLabel: 'portrait_t6_dom_c_cta',
        cta: CtaAction.audioTrack('removing_armor'),
      ),
      'D': PortraitDominantContent(
        label: 'portrait_t6_dom_d_title',
        light: 'portrait_t6_dom_d_light',
        shadow: 'portrait_t6_dom_d_shadow',
        ctaLabel: 'portrait_t6_dom_d_cta',
        cta: CtaAction.audioTrack('right_to_pause'),
      ),
    },
  ),

  PortraitTestId.rightToPause: PortraitTestDefinition(
    title: 'portrait_t7_title',
    intro: 'portrait_t7_intro',
    questions: const [
      PortraitQuestion(
        'portrait_t7_q1',
        [
          PortraitOption('portrait_t7_q1_a', 'A'),
          PortraitOption('portrait_t7_q1_b', 'B'),
          PortraitOption('portrait_t7_q1_c', 'C'),
          PortraitOption('portrait_t7_q1_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t7_q2',
        [
          PortraitOption('portrait_t7_q2_a', 'A'),
          PortraitOption('portrait_t7_q2_b', 'B'),
          PortraitOption('portrait_t7_q2_c', 'C'),
          PortraitOption('portrait_t7_q2_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t7_q3',
        [
          PortraitOption('portrait_t7_q3_a', 'A'),
          PortraitOption('portrait_t7_q3_b', 'B'),
          PortraitOption('portrait_t7_q3_c', 'C'),
          PortraitOption('portrait_t7_q3_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t7_q4',
        [
          PortraitOption('portrait_t7_q4_a', 'A'),
          PortraitOption('portrait_t7_q4_b', 'B'),
          PortraitOption('portrait_t7_q4_c', 'C'),
          PortraitOption('portrait_t7_q4_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t7_q5',
        [
          PortraitOption('portrait_t7_q5_a', 'A'),
          PortraitOption('portrait_t7_q5_b', 'B'),
          PortraitOption('portrait_t7_q5_c', 'C'),
          PortraitOption('portrait_t7_q5_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t7_q6',
        [
          PortraitOption('portrait_t7_q6_a', 'A'),
          PortraitOption('portrait_t7_q6_b', 'B'),
          PortraitOption('portrait_t7_q6_c', 'C'),
          PortraitOption('portrait_t7_q6_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t7_q7',
        [
          PortraitOption('portrait_t7_q7_a', 'A'),
          PortraitOption('portrait_t7_q7_b', 'B'),
          PortraitOption('portrait_t7_q7_c', 'C'),
          PortraitOption('portrait_t7_q7_d', 'D'),
        ],
      ),
    ],
    dominants: {
      'A': PortraitDominantContent(
        label: 'portrait_t7_dom_a_title',
        light: 'portrait_t7_dom_a_light',
        shadow: 'portrait_t7_dom_a_shadow',
        ctaLabel: 'portrait_t7_dom_a_cta',
        cta: CtaAction.audioTrack('right_to_pause'),
      ),
      'B': PortraitDominantContent(
        label: 'portrait_t7_dom_b_title',
        light: 'portrait_t7_dom_b_light',
        shadow: 'portrait_t7_dom_b_shadow',
        ctaLabel: 'portrait_t7_dom_b_cta',
        cta: CtaAction.challengeDo,
      ),
      'C': PortraitDominantContent(
        label: 'portrait_t7_dom_c_title',
        light: 'portrait_t7_dom_c_light',
        shadow: 'portrait_t7_dom_c_shadow',
        ctaLabel: 'portrait_t7_dom_c_cta',
        cta: CtaAction.desiresScreen,
      ),
      'D': PortraitDominantContent(
        label: 'portrait_t7_dom_d_title',
        light: 'portrait_t7_dom_d_light',
        shadow: 'portrait_t7_dom_d_shadow',
        ctaLabel: 'portrait_t7_dom_d_cta',
        cta: CtaAction.challengeThought,
      ),
    },
  ),

  PortraitTestId.innerDefender: PortraitTestDefinition(
    title: 'portrait_t8_title',
    intro: 'portrait_t8_intro',
    questions: const [
      PortraitQuestion(
        'portrait_t8_q1',
        [
          PortraitOption('portrait_t8_q1_a', 'A'),
          PortraitOption('portrait_t8_q1_b', 'B'),
          PortraitOption('portrait_t8_q1_c', 'C'),
          PortraitOption('portrait_t8_q1_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t8_q2',
        [
          PortraitOption('portrait_t8_q2_a', 'A'),
          PortraitOption('portrait_t8_q2_b', 'B'),
          PortraitOption('portrait_t8_q2_c', 'C'),
          PortraitOption('portrait_t8_q2_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t8_q3',
        [
          PortraitOption('portrait_t8_q3_a', 'A'),
          PortraitOption('portrait_t8_q3_b', 'B'),
          PortraitOption('portrait_t8_q3_c', 'C'),
          PortraitOption('portrait_t8_q3_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t8_q4',
        [
          PortraitOption('portrait_t8_q4_a', 'A'),
          PortraitOption('portrait_t8_q4_b', 'B'),
          PortraitOption('portrait_t8_q4_c', 'C'),
          PortraitOption('portrait_t8_q4_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t8_q5',
        [
          PortraitOption('portrait_t8_q5_a', 'A'),
          PortraitOption('portrait_t8_q5_b', 'B'),
          PortraitOption('portrait_t8_q5_c', 'C'),
          PortraitOption('portrait_t8_q5_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t8_q6',
        [
          PortraitOption('portrait_t8_q6_a', 'A'),
          PortraitOption('portrait_t8_q6_b', 'B'),
          PortraitOption('portrait_t8_q6_c', 'C'),
          PortraitOption('portrait_t8_q6_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t8_q7',
        [
          PortraitOption('portrait_t8_q7_a', 'A'),
          PortraitOption('portrait_t8_q7_b', 'B'),
          PortraitOption('portrait_t8_q7_c', 'C'),
          PortraitOption('portrait_t8_q7_d', 'D'),
        ],
      ),
    ],
    dominants: {
      'A': PortraitDominantContent(
        label: 'portrait_t8_dom_a_title',
        light: 'portrait_t8_dom_a_light',
        shadow: 'portrait_t8_dom_a_shadow',
        ctaLabel: 'portrait_t8_dom_a_cta',
        cta: CtaAction.audioTrack('reactor_cooling'),
      ),
      'B': PortraitDominantContent(
        label: 'portrait_t8_dom_b_title',
        light: 'portrait_t8_dom_b_light',
        shadow: 'portrait_t8_dom_b_shadow',
        // No dedicated somatic-scan screen exists yet — temporary substitute
        // per the approved plan, marked explicitly rather than invented.
        ctaLabel: 'portrait_t8_dom_b_cta',
        cta: CtaAction.audioTrack('reactor_cooling'),
      ),
      'C': PortraitDominantContent(
        label: 'portrait_t8_dom_c_title',
        light: 'portrait_t8_dom_c_light',
        shadow: 'portrait_t8_dom_c_shadow',
        ctaLabel: 'portrait_t8_dom_c_cta',
        cta: CtaAction.challengeDo,
      ),
      'D': PortraitDominantContent(
        label: 'portrait_t8_dom_d_title',
        light: 'portrait_t8_dom_d_light',
        shadow: 'portrait_t8_dom_d_shadow',
        ctaLabel: 'portrait_t8_dom_d_cta',
        cta: CtaAction.socialBattery,
      ),
    },
  ),

  PortraitTestId.trueCompass: PortraitTestDefinition(
    title: 'portrait_t9_title',
    intro: 'portrait_t9_intro',
    questions: const [
      PortraitQuestion(
        'portrait_t9_q1',
        [
          PortraitOption('portrait_t9_q1_a', 'A'),
          PortraitOption('portrait_t9_q1_b', 'B'),
          PortraitOption('portrait_t9_q1_c', 'C'),
          PortraitOption('portrait_t9_q1_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t9_q2',
        [
          PortraitOption('portrait_t9_q2_a', 'A'),
          PortraitOption('portrait_t9_q2_b', 'B'),
          PortraitOption('portrait_t9_q2_c', 'C'),
          PortraitOption('portrait_t9_q2_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t9_q3',
        [
          PortraitOption('portrait_t9_q3_a', 'A'),
          PortraitOption('portrait_t9_q3_b', 'B'),
          PortraitOption('portrait_t9_q3_c', 'C'),
          PortraitOption('portrait_t9_q3_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t9_q4',
        [
          PortraitOption('portrait_t9_q4_a', 'A'),
          PortraitOption('portrait_t9_q4_b', 'B'),
          PortraitOption('portrait_t9_q4_c', 'C'),
          PortraitOption('portrait_t9_q4_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t9_q5',
        [
          PortraitOption('portrait_t9_q5_a', 'A'),
          PortraitOption('portrait_t9_q5_b', 'B'),
          PortraitOption('portrait_t9_q5_c', 'C'),
          PortraitOption('portrait_t9_q5_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t9_q6',
        [
          PortraitOption('portrait_t9_q6_a', 'A'),
          PortraitOption('portrait_t9_q6_b', 'B'),
          PortraitOption('portrait_t9_q6_c', 'C'),
          PortraitOption('portrait_t9_q6_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t9_q7',
        [
          PortraitOption('portrait_t9_q7_a', 'A'),
          PortraitOption('portrait_t9_q7_b', 'B'),
          PortraitOption('portrait_t9_q7_c', 'C'),
          PortraitOption('portrait_t9_q7_d', 'D'),
        ],
      ),
    ],
    dominants: {
      'A': PortraitDominantContent(
        label: 'portrait_t9_dom_a_title',
        light: 'portrait_t9_dom_a_light',
        shadow: 'portrait_t9_dom_a_shadow',
        ctaLabel: 'portrait_t9_dom_a_cta',
        cta: CtaAction.challengeThought,
      ),
      'B': PortraitDominantContent(
        label: 'portrait_t9_dom_b_title',
        light: 'portrait_t9_dom_b_light',
        shadow: 'portrait_t9_dom_b_shadow',
        ctaLabel: 'portrait_t9_dom_b_cta',
        cta: CtaAction.happinessInFocus,
      ),
      'C': PortraitDominantContent(
        label: 'portrait_t9_dom_c_title',
        light: 'portrait_t9_dom_c_light',
        shadow: 'portrait_t9_dom_c_shadow',
        ctaLabel: 'portrait_t9_dom_c_cta',
        cta: CtaAction.desiresScreen,
      ),
      'D': PortraitDominantContent(
        label: 'portrait_t9_dom_d_title',
        light: 'portrait_t9_dom_d_light',
        shadow: 'portrait_t9_dom_d_shadow',
        ctaLabel: 'portrait_t9_dom_d_cta',
        cta: CtaAction.audioTrack('removing_armor'),
      ),
    },
  ),

  PortraitTestId.innerVoice: PortraitTestDefinition(
    title: 'portrait_t10_title',
    intro: 'portrait_t10_intro',
    questions: const [
      PortraitQuestion(
        'portrait_t10_q1',
        [
          PortraitOption('portrait_t10_q1_a', 'A'),
          PortraitOption('portrait_t10_q1_b', 'B'),
          PortraitOption('portrait_t10_q1_c', 'C'),
          PortraitOption('portrait_t10_q1_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t10_q2',
        [
          PortraitOption('portrait_t10_q2_a', 'A'),
          PortraitOption('portrait_t10_q2_b', 'B'),
          PortraitOption('portrait_t10_q2_c', 'C'),
          PortraitOption('portrait_t10_q2_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t10_q3',
        [
          PortraitOption('portrait_t10_q3_a', 'A'),
          PortraitOption('portrait_t10_q3_b', 'B'),
          PortraitOption('portrait_t10_q3_c', 'C'),
          PortraitOption('portrait_t10_q3_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t10_q4',
        [
          PortraitOption('portrait_t10_q4_a', 'A'),
          PortraitOption('portrait_t10_q4_b', 'B'),
          PortraitOption('portrait_t10_q4_c', 'C'),
          PortraitOption('portrait_t10_q4_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t10_q5',
        [
          PortraitOption('portrait_t10_q5_a', 'A'),
          PortraitOption('portrait_t10_q5_b', 'B'),
          PortraitOption('portrait_t10_q5_c', 'C'),
          PortraitOption('portrait_t10_q5_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t10_q6',
        [
          PortraitOption('portrait_t10_q6_a', 'A'),
          PortraitOption('portrait_t10_q6_b', 'B'),
          PortraitOption('portrait_t10_q6_c', 'C'),
          PortraitOption('portrait_t10_q6_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t10_q7',
        [
          PortraitOption('portrait_t10_q7_a', 'A'),
          PortraitOption('portrait_t10_q7_b', 'B'),
          PortraitOption('portrait_t10_q7_c', 'C'),
          PortraitOption('portrait_t10_q7_d', 'D'),
        ],
      ),
    ],
    dominants: {
      'A': PortraitDominantContent(
        label: 'portrait_t10_dom_a_title',
        light: 'portrait_t10_dom_a_light',
        shadow: 'portrait_t10_dom_a_shadow',
        ctaLabel: 'portrait_t10_dom_a_cta',
        cta: CtaAction.challengeThought,
      ),
      'B': PortraitDominantContent(
        label: 'portrait_t10_dom_b_title',
        light: 'portrait_t10_dom_b_light',
        shadow: 'portrait_t10_dom_b_shadow',
        ctaLabel: 'portrait_t10_dom_b_cta',
        cta: CtaAction.challengeDo,
      ),
      'C': PortraitDominantContent(
        label: 'portrait_t10_dom_c_title',
        light: 'portrait_t10_dom_c_light',
        shadow: 'portrait_t10_dom_c_shadow',
        ctaLabel: 'portrait_t10_dom_c_cta',
        cta: CtaAction.audioTrack('removing_armor'),
      ),
      'D': PortraitDominantContent(
        label: 'portrait_t10_dom_d_title',
        light: 'portrait_t10_dom_d_light',
        shadow: 'portrait_t10_dom_d_shadow',
        ctaLabel: 'portrait_t10_dom_d_cta',
        cta: CtaAction.happinessInFocus,
      ),
    },
  ),

  PortraitTestId.attachmentStyle: PortraitTestDefinition(
    title: 'portrait_t11_title',
    intro: 'portrait_t11_intro',
    requiresDisclaimer: true,
    questions: const [
      PortraitQuestion(
        'portrait_t11_q1',
        [
          PortraitOption('portrait_t11_q1_a', 'A'),
          PortraitOption('portrait_t11_q1_b', 'B'),
          PortraitOption('portrait_t11_q1_c', 'C'),
          PortraitOption('portrait_t11_q1_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t11_q2',
        [
          PortraitOption('portrait_t11_q2_a', 'A'),
          PortraitOption('portrait_t11_q2_b', 'B'),
          PortraitOption('portrait_t11_q2_c', 'C'),
          PortraitOption('portrait_t11_q2_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t11_q3',
        [
          PortraitOption('portrait_t11_q3_a', 'A'),
          PortraitOption('portrait_t11_q3_b', 'B'),
          PortraitOption('portrait_t11_q3_c', 'C'),
          PortraitOption('portrait_t11_q3_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t11_q4',
        [
          PortraitOption('portrait_t11_q4_a', 'A'),
          PortraitOption('portrait_t11_q4_b', 'B'),
          PortraitOption('portrait_t11_q4_c', 'C'),
          PortraitOption('portrait_t11_q4_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t11_q5',
        [
          PortraitOption('portrait_t11_q5_a', 'A'),
          PortraitOption('portrait_t11_q5_b', 'B'),
          PortraitOption('portrait_t11_q5_c', 'C'),
          PortraitOption('portrait_t11_q5_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t11_q6',
        [
          PortraitOption('portrait_t11_q6_a', 'A'),
          PortraitOption('portrait_t11_q6_b', 'B'),
          PortraitOption('portrait_t11_q6_c', 'C'),
          PortraitOption('portrait_t11_q6_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t11_q7',
        [
          PortraitOption('portrait_t11_q7_a', 'A'),
          PortraitOption('portrait_t11_q7_b', 'B'),
          PortraitOption('portrait_t11_q7_c', 'C'),
          PortraitOption('portrait_t11_q7_d', 'D'),
        ],
      ),
    ],
    dominants: {
      'A': PortraitDominantContent(
        label: 'portrait_t11_dom_a_title',
        light: 'portrait_t11_dom_a_light',
        shadow: 'portrait_t11_dom_a_shadow',
        ctaLabel: 'portrait_t11_dom_a_cta',
        cta: CtaAction.desiresScreen,
      ),
      'B': PortraitDominantContent(
        label: 'portrait_t11_dom_b_title',
        light: 'portrait_t11_dom_b_light',
        shadow: 'portrait_t11_dom_b_shadow',
        ctaLabel: 'portrait_t11_dom_b_cta',
        cta: CtaAction.socialBattery,
      ),
      'C': PortraitDominantContent(
        label: 'portrait_t11_dom_c_title',
        light: 'portrait_t11_dom_c_light',
        shadow: 'portrait_t11_dom_c_shadow',
        ctaLabel: 'portrait_t11_dom_c_cta',
        cta: CtaAction.challengeDo,
      ),
      'D': PortraitDominantContent(
        label: 'portrait_t11_dom_d_title',
        light: 'portrait_t11_dom_d_light',
        shadow: 'portrait_t11_dom_d_shadow',
        ctaLabel: 'portrait_t11_dom_d_cta',
        cta: CtaAction.audioTrack('reactor_cooling'),
      ),
    },
  ),

  PortraitTestId.futureOutlook: PortraitTestDefinition(
    title: 'portrait_t12_title',
    intro: 'portrait_t12_intro',
    questions: const [
      PortraitQuestion(
        'portrait_t12_q1',
        [
          PortraitOption('portrait_t12_q1_a', 'A'),
          PortraitOption('portrait_t12_q1_b', 'B'),
          PortraitOption('portrait_t12_q1_c', 'C'),
          PortraitOption('portrait_t12_q1_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t12_q2',
        [
          PortraitOption('portrait_t12_q2_a', 'A'),
          PortraitOption('portrait_t12_q2_b', 'B'),
          PortraitOption('portrait_t12_q2_c', 'C'),
          PortraitOption('portrait_t12_q2_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t12_q3',
        [
          PortraitOption('portrait_t12_q3_a', 'A'),
          PortraitOption('portrait_t12_q3_b', 'B'),
          PortraitOption('portrait_t12_q3_c', 'C'),
          PortraitOption('portrait_t12_q3_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t12_q4',
        [
          PortraitOption('portrait_t12_q4_a', 'A'),
          PortraitOption('portrait_t12_q4_b', 'B'),
          PortraitOption('portrait_t12_q4_c', 'C'),
          PortraitOption('portrait_t12_q4_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t12_q5',
        [
          PortraitOption('portrait_t12_q5_a', 'A'),
          PortraitOption('portrait_t12_q5_b', 'B'),
          PortraitOption('portrait_t12_q5_c', 'C'),
          PortraitOption('portrait_t12_q5_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t12_q6',
        [
          PortraitOption('portrait_t12_q6_a', 'A'),
          PortraitOption('portrait_t12_q6_b', 'B'),
          PortraitOption('portrait_t12_q6_c', 'C'),
          PortraitOption('portrait_t12_q6_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_t12_q7',
        [
          PortraitOption('portrait_t12_q7_a', 'A'),
          PortraitOption('portrait_t12_q7_b', 'B'),
          PortraitOption('portrait_t12_q7_c', 'C'),
          PortraitOption('portrait_t12_q7_d', 'D'),
        ],
      ),
    ],
    dominants: {
      'A': PortraitDominantContent(
        label: 'portrait_t12_dom_a_title',
        light: 'portrait_t12_dom_a_light',
        shadow: 'portrait_t12_dom_a_shadow',
        ctaLabel: 'portrait_t12_dom_a_cta',
        cta: CtaAction.audioTrack('removing_armor'),
      ),
      'B': PortraitDominantContent(
        label: 'portrait_t12_dom_b_title',
        light: 'portrait_t12_dom_b_light',
        shadow: 'portrait_t12_dom_b_shadow',
        ctaLabel: 'portrait_t12_dom_b_cta',
        cta: CtaAction.desiresScreen,
      ),
      'C': PortraitDominantContent(
        label: 'portrait_t12_dom_c_title',
        light: 'portrait_t12_dom_c_light',
        shadow: 'portrait_t12_dom_c_shadow',
        ctaLabel: 'portrait_t12_dom_c_cta',
        cta: CtaAction.challengeThought,
      ),
      'D': PortraitDominantContent(
        label: 'portrait_t12_dom_d_title',
        light: 'portrait_t12_dom_d_light',
        shadow: 'portrait_t12_dom_d_shadow',
        ctaLabel: 'portrait_t12_dom_d_cta',
        cta: CtaAction.challengeDo,
      ),
    },
  ),

  PortraitTestId.bonusChronotype: PortraitTestDefinition(
    title: 'portrait_tbonus_title',
    intro: 'portrait_tbonus_intro',
    questions: const [
      PortraitQuestion(
        'portrait_tbonus_q1',
        [
          PortraitOption('portrait_tbonus_q1_a', 'A'),
          PortraitOption('portrait_tbonus_q1_b', 'B'),
          PortraitOption('portrait_tbonus_q1_c', 'C'),
          PortraitOption('portrait_tbonus_q1_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_tbonus_q2',
        [
          PortraitOption('portrait_tbonus_q2_a', 'A'),
          PortraitOption('portrait_tbonus_q2_b', 'B'),
          PortraitOption('portrait_tbonus_q2_c', 'C'),
          PortraitOption('portrait_tbonus_q2_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_tbonus_q3',
        [
          PortraitOption('portrait_tbonus_q3_a', 'A'),
          PortraitOption('portrait_tbonus_q3_b', 'B'),
          PortraitOption('portrait_tbonus_q3_c', 'C'),
          PortraitOption('portrait_tbonus_q3_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_tbonus_q4',
        [
          PortraitOption('portrait_tbonus_q4_a', 'A'),
          PortraitOption('portrait_tbonus_q4_b', 'B'),
          PortraitOption('portrait_tbonus_q4_c', 'C'),
          PortraitOption('portrait_tbonus_q4_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_tbonus_q5',
        [
          PortraitOption('portrait_tbonus_q5_a', 'A'),
          PortraitOption('portrait_tbonus_q5_b', 'B'),
          PortraitOption('portrait_tbonus_q5_c', 'C'),
          PortraitOption('portrait_tbonus_q5_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_tbonus_q6',
        [
          PortraitOption('portrait_tbonus_q6_a', 'A'),
          PortraitOption('portrait_tbonus_q6_b', 'B'),
          PortraitOption('portrait_tbonus_q6_c', 'C'),
          PortraitOption('portrait_tbonus_q6_d', 'D'),
        ],
      ),
      PortraitQuestion(
        'portrait_tbonus_q7',
        [
          PortraitOption('portrait_tbonus_q7_a', 'A'),
          PortraitOption('portrait_tbonus_q7_b', 'B'),
          PortraitOption('portrait_tbonus_q7_c', 'C'),
          PortraitOption('portrait_tbonus_q7_d', 'D'),
        ],
      ),
    ],
    dominants: {
      'A': PortraitDominantContent(
        label: 'portrait_tbonus_dom_a_title',
        light: 'portrait_tbonus_dom_a_light',
        shadow: 'portrait_tbonus_dom_a_shadow',
        ctaLabel: 'portrait_tbonus_dom_a_cta',
        cta: CtaAction.audioTrack('right_to_pause'),
      ),
      'B': PortraitDominantContent(
        label: 'portrait_tbonus_dom_b_title',
        light: 'portrait_tbonus_dom_b_light',
        shadow: 'portrait_tbonus_dom_b_shadow',
        ctaLabel: 'portrait_tbonus_dom_b_cta',
        cta: CtaAction.energyMatrix,
      ),
      'C': PortraitDominantContent(
        label: 'portrait_tbonus_dom_c_title',
        light: 'portrait_tbonus_dom_c_light',
        shadow: 'portrait_tbonus_dom_c_shadow',
        ctaLabel: 'portrait_tbonus_dom_c_cta',
        cta: CtaAction.energyMatrix,
      ),
      'D': PortraitDominantContent(
        label: 'portrait_tbonus_dom_d_title',
        light: 'portrait_tbonus_dom_d_light',
        shadow: 'portrait_tbonus_dom_d_shadow',
        ctaLabel: 'portrait_tbonus_dom_d_cta',
        cta: CtaAction.audioTrack('right_to_pause'),
      ),
    },
  ),
};
