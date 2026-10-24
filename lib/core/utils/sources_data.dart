// Sources shown in Settings -> «Источники и научная основа» (App Store
// Review Guideline 1.4.1: medical/health information must cite its sources).
// Every DOI below was checked against Crossref (title, first author, year,
// journal) on 2026-10-23. Titles stay in the original (English).

class SourceRef {
  final String authors;
  final int year;
  final String title;
  final String journal;
  final String doi;
  const SourceRef(this.authors, this.year, this.title, this.journal, this.doi);

  String get url => 'https://doi.org/$doi';
}

class SourceTopic {
  final String titleKey;
  final List<SourceRef> refs;
  const SourceTopic(this.titleKey, this.refs);
}

class GeneralSource {
  final String titleKey;
  final String org;
  final String url;
  const GeneralSource(this.titleKey, this.org, this.url);
}

const List<GeneralSource> kGeneralSources = [
  GeneralSource('src_gen_who_mh', 'WHO', 'https://www.who.int/news-room/fact-sheets/detail/mental-health-strengthening-our-response'),
  GeneralSource('src_gen_who_dep', 'WHO', 'https://www.who.int/news-room/fact-sheets/detail/depression'),
  GeneralSource('src_gen_who_anx', 'WHO', 'https://www.who.int/news-room/fact-sheets/detail/anxiety-disorders'),
  GeneralSource('src_gen_nimh', 'NIMH (USA)', 'https://www.nimh.nih.gov/health/topics/psychotherapies'),
  GeneralSource('src_gen_nice', 'NICE (UK)', 'https://www.nice.org.uk/guidance/ng222'),
  GeneralSource('src_gen_apa', 'APA (USA)', 'https://www.apa.org/ptsd-guideline/treatments/cognitive-behavioral-therapy'),
];

const List<SourceTopic> kSourceTopics = [
  SourceTopic('src_topic_breathing', [
    SourceRef('Balban et al.', 2023, 'Brief structured respiration practices enhance mood and reduce physiological arousal', 'Cell Reports Medicine', '10.1016/j.xcrm.2022.100895'),
  ]),
  SourceTopic('src_topic_urges', [
    SourceRef('Torre et al.', 2018, 'Putting Feelings Into Words: Affect Labeling as Implicit Emotion Regulation', 'Emotion Review', '10.1177/1754073917742706'),
    SourceRef('Bowen et al.', 2009, 'Surfing the urge: Brief mindfulness-based intervention for college student smokers', 'Psychology of Addictive Behaviors', '10.1037/a0017127'),
  ]),
  SourceTopic('src_topic_thoughts', [
    SourceRef('Masuda et al.', 2004, 'Cognitive defusion and self-relevant negative thoughts: examining the impact of a ninety year old technique', 'Behaviour Research and Therapy', '10.1016/j.brat.2003.10.008'),
    SourceRef('Hayes et al.', 2006, 'Acceptance and Commitment Therapy: Model, processes and outcomes', 'Behaviour Research and Therapy', '10.1016/j.brat.2005.06.006'),
    SourceRef('Gloster et al.', 2020, 'The empirical status of acceptance and commitment therapy: A review of meta-analyses', 'Journal of Contextual Behavioral Science', '10.1016/j.jcbs.2020.09.009'),
    SourceRef('Levin et al.', 2012, 'The Impact of Treatment Components Suggested by the Psychological Flexibility Model: A Meta-Analysis of Laboratory-Based Component Studies', 'Behavior Therapy', '10.1016/j.beth.2012.05.003'),
    SourceRef('Nolen-Hoeksema et al.', 2008, 'Rethinking Rumination', 'Perspectives on Psychological Science', '10.1111/j.1745-6924.2008.00088.x'),
    SourceRef('Wegner et al.', 1987, 'Paradoxical effects of thought suppression', 'Journal of Personality and Social Psychology', '10.1037/0022-3514.53.1.5'),
    SourceRef('Abramowitz et al.', 2001, 'Paradoxical effects of thought suppression: a meta-analysis of controlled studies', 'Clinical Psychology Review', '10.1016/S0272-7358(00)00057-X'),
  ]),
  SourceTopic('src_topic_compassion', [
    SourceRef('Neff', 2003, 'Self-Compassion: An Alternative Conceptualization of a Healthy Attitude Toward Oneself', 'Self and Identity', '10.1080/15298860309032'),
    SourceRef('Ferrari et al.', 2019, 'Self-Compassion Interventions and Psychosocial Outcomes: a Meta-Analysis of RCTs', 'Mindfulness', '10.1007/s12671-019-01134-6'),
    SourceRef('Gilbert et al.', 2011, 'Fears of compassion: Development of three self‐report measures', 'Psychology and Psychotherapy: Theory, Research and Practice', '10.1348/147608310X526511'),
    SourceRef('Kross et al.', 2014, 'Self-talk as a regulatory mechanism: How you do it matters', 'Journal of Personality and Social Psychology', '10.1037/a0035173'),
  ]),
  SourceTopic('src_topic_action', [
    SourceRef('Ekers et al.', 2014, 'Behavioural Activation for Depression; An Update of Meta-Analysis of Effectiveness and Sub Group Analysis', 'PLoS ONE', '10.1371/journal.pone.0100100'),
    SourceRef('Gollwitzer et al.', 2006, 'Implementation Intentions and Goal Achievement: A Meta‐analysis of Effects and Processes', 'Advances in Experimental Social Psychology', '10.1016/S0065-2601(06)38002-1'),
  ]),
  SourceTopic('src_topic_relationships', [
    SourceRef('Fisher et al.', 2010, 'Reward, Addiction, and Emotion Regulation Systems Associated With Rejection in Love', 'Journal of Neurophysiology', '10.1152/jn.00784.2009'),
    SourceRef('Sbarra et al.', 2012, 'When Leaving Your Ex, Love Yourself', 'Psychological Science', '10.1177/0956797611429466'),
    SourceRef('Larson et al.', 2015, 'Participating in Research on Romantic Breakups Promotes Emotional Recovery via Changes in Self-Concept Clarity', 'Social Psychological and Personality Science', '10.1177/1948550614563085'),
    SourceRef('Langeslag et al.', 2018, 'Down-regulation of love feelings after a romantic break-up: Self-report and electrophysiological data', 'Journal of Experimental Psychology: General', '10.1037/xge0000360'),
    SourceRef('Marshall', 2012, 'Facebook Surveillance of Former Romantic Partners: Associations with PostBreakup Recovery and Personal Growth', 'Cyberpsychology, Behavior, and Social Networking', '10.1089/cyber.2012.0125'),
    SourceRef('Fox et al.', 2015, 'Romantic Partner Monitoring After Breakups: Attachment, Dependence, Distress, and Post-Dissolution Online Surveillance via Social Networking Sites', 'Cyberpsychology, Behavior, and Social Networking', '10.1089/cyber.2015.0123'),
    SourceRef('Lewandowski', 2009, 'Promoting positive emotions following relationship dissolution through writing', 'The Journal of Positive Psychology', '10.1080/17439760802068480'),
  ]),
  SourceTopic('src_topic_safety', [
    SourceRef('Britton et al.', 2021, 'Defining and Measuring Meditation-Related Adverse Effects in Mindfulness-Based Programs', 'Clinical Psychological Science', '10.1177/2167702621996340'),
    SourceRef('Linardon et al.', 2019, 'The efficacy of app‐supported smartphone interventions for mental health problems: a meta‐analysis of randomized controlled trials', 'World Psychiatry', '10.1002/wps.20673'),
  ]),
];
