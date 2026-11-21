// Sources of the depression-support course «Опора» (and any later course that
// names them in its JSON: "basis_refs" / "source_ids"). Journal articles carry a
// DOI that was checked against Crossref (title, first author, year, journal) on
// 2026-11-20; guidelines and books link to the publisher's or issuer's page.
// Titles stay in the original language.
//
// Evidence in these sources comes from methods delivered by specialists or with
// specialist support. None of them tested this app.

enum CourseSourceKind { guideline, review, trial, book }

class CourseSource {
  final String id;
  final CourseSourceKind kind;
  final String citation;
  final String url;
  const CourseSource(this.id, this.kind, this.citation, this.url);
}

String _doi(String doi) => 'https://doi.org/$doi';

final Map<String, CourseSource> kCourseSources = {
  for (final s in _all) s.id: s,
};

CourseSource? courseSourceById(String id) => kCourseSources[id];

final List<CourseSource> _all = [
  // Guidelines
  // The protocol the course follows
  const CourseSource('munoz2000', CourseSourceKind.book,
      'Muñoz R.F., Ghosh Ippen C., Rao S., Le H.-N., Dwyer E.V. (2000). Manual for Group Cognitive-Behavioral Therapy of Major Depression: A Reality Management Approach (Instructor\'s Manual). Cognitive-Behavioral Depression Clinic, San Francisco General Hospital, University of California, San Francisco.',
      'https://i4health.paloaltou.edu/manuals/group-cbt.html'),
  const CourseSource('munoz1986', CourseSourceKind.book,
      'Muñoz R.F., Miranda J. (1986; RAND edition 2000). Group Therapy Manual for Cognitive-Behavioral Treatment of Depression (12 sessions). RAND, MR-1198/4.',
      'https://www.rand.org/pubs/monograph_reports/MR1198z4.html'),
  CourseSource('zeiss1979', CourseSourceKind.trial,
      'Zeiss A.M., Lewinsohn P.M., Muñoz R.F. (1979). Nonspecific improvement effects in depression using interpersonal skills training, pleasant activity schedules, or cognitive training. Journal of Consulting and Clinical Psychology, 47(3), 427-439.',
      _doi('10.1037/0022-006X.47.3.427')),
  CourseSource('wells2000', CourseSourceKind.trial,
      'Wells K.B. et al. (2000). Impact of disseminating quality improvement programs for depression in managed primary care: a randomized controlled trial. JAMA, 283(2), 212-220.',
      _doi('10.1001/jama.283.2.212')),
  const CourseSource(
      'nice_ng222',
      CourseSourceKind.guideline,
      'NICE (2022). Depression in adults: treatment and management (NG222).',
      'https://www.nice.org.uk/guidance/ng222'),
  const CourseSource(
      'apa_2019',
      CourseSourceKind.guideline,
      'American Psychological Association (2019). Clinical Practice Guideline for the Treatment of Depression Across Three Age Cohorts.',
      'https://www.apa.org/depression-guideline'),
  const CourseSource(
      'mhgap',
      CourseSourceKind.guideline,
      'WHO (2016). mhGAP Intervention Guide for mental, neurological and substance use disorders in non-specialized health settings, version 2.0.',
      'https://www.who.int/publications/i/item/9789241549790'),
  const CourseSource(
      'ru_kr',
      CourseSourceKind.guideline,
      'Российское общество психиатров, Минздрав России. Клинические рекомендации «Депрессивный эпизод, рекуррентное депрессивное расстройство» (взрослые). Актуальную редакцию смотрите в рубрикаторе клинических рекомендаций.',
      'https://cr.minzdrav.gov.ru/'),
  // Cognitive and behavioural methods
  const CourseSource(
      'beck1979',
      CourseSourceKind.book,
      'Beck A.T., Rush A.J., Shaw B.F., Emery G. (1979). Cognitive Therapy of Depression. Guilford Press.',
      'https://www.guilford.com/books/Cognitive-Therapy-of-Depression/Beck-Rush-Shaw-Emery/9780898629194'),
  const CourseSource(
      'greenberger2016',
      CourseSourceKind.book,
      'Greenberger D., Padesky C.A. (2016). Mind Over Mood: Change How You Feel by Changing the Way You Think, 2nd ed. Guilford Press.',
      'https://www.guilford.com/books/Mind-Over-Mood/Greenberger-Padesky/9781462520428'),
  const CourseSource(
      'martell2021',
      CourseSourceKind.book,
      'Martell C.R., Dimidjian S., Herman-Dunn R. (2021). Behavioral Activation for Depression: A Clinician\'s Guide, 2nd ed. Guilford Press.',
      'https://www.guilford.com/books/Behavioral-Activation-for-Depression/Martell-Dimidjian-Herman-Dunn/9781462548385'),
  CourseSource(
      'lejuez2011',
      CourseSourceKind.trial,
      'Lejuez C.W., Hopko D.R., Acierno R., Daughters S.B., Pagoto S.L. (2011). Ten year revision of the brief behavioral activation treatment for depression: revised treatment manual. Behavior Modification, 35(2), 111-161.',
      _doi('10.1177/0145445510390929')),
  CourseSource(
      'ekers2014',
      CourseSourceKind.review,
      'Ekers D. et al. (2014). Behavioural activation for depression; an update of meta-analysis of effectiveness and sub group analysis. PLoS ONE, 9(6), e100100.',
      _doi('10.1371/journal.pone.0100100')),
  CourseSource(
      'richards2016',
      CourseSourceKind.trial,
      'Richards D.A. et al. (2016). Cost and outcome of behavioural activation versus cognitive behavioural therapy for depression (COBRA): a randomised, controlled, non-inferiority trial. The Lancet, 388, 871-880.',
      _doi('10.1016/S0140-6736(16)31140-0')),
    CourseSource(
      'patel2017',
      CourseSourceKind.trial,
      'Patel V. et al. (2017). The Healthy Activity Program (HAP), a lay counsellor-delivered brief psychological treatment for severe depression, in primary care in India: a randomised controlled trial. The Lancet, 389, 176-185.',
      _doi('10.1016/S0140-6736(16)31589-6')),
  CourseSource(
      'cuijpers2013',
      CourseSourceKind.review,
      'Cuijpers P. et al. (2013). A meta-analysis of cognitive-behavioural therapy for adult depression, alone and in comparison with other treatments. The Canadian Journal of Psychiatry, 58(7), 376-385.',
      _doi('10.1177/070674371305800702')),
  CourseSource(
      'cuijpers2007',
      CourseSourceKind.review,
      'Cuijpers P., van Straten A., Warmerdam L. (2007). Problem solving therapies for depression: a meta-analysis. European Psychiatry, 22(1), 9-15.',
      _doi('10.1016/j.eurpsy.2006.11.001')),
  CourseSource(
      'noetel2024',
      CourseSourceKind.review,
      'Noetel M. et al. (2024). Effect of exercise for depression: systematic review and network meta-analysis of randomised controlled trials. BMJ, 384, e075847.',
      _doi('10.1136/bmj-2023-075847')),
  CourseSource(
      'nolen2008',
      CourseSourceKind.review,
      'Nolen-Hoeksema S., Wisco B.E., Lyubomirsky S. (2008). Rethinking rumination. Perspectives on Psychological Science, 3(5), 400-424.',
      _doi('10.1111/j.1745-6924.2008.00088.x')),
  // Dialectical behaviour therapy skills
  const CourseSource(
      'linehan2015',
      CourseSourceKind.book,
      'Linehan M.M. (2015). DBT Skills Training Manual, 2nd ed. Guilford Press.',
      'https://www.guilford.com/books/DBT-Skills-Training-Manual/Marsha-Linehan/9781462516995'),
  CourseSource(
      'lynch2003',
      CourseSourceKind.trial,
      'Lynch T.R., Morse J.Q., Mendelson T., Robins C.J. (2003). Dialectical behavior therapy for depressed older adults: a randomized pilot study. American Journal of Geriatric Psychiatry, 11(1), 33-45.',
      _doi('10.1176/appi.ajgp.11.1.33')),
  CourseSource(
      'harley2008',
      CourseSourceKind.trial,
      'Harley R., Sprich S., Safren S., Jacobo M., Fava M. (2008). Adaptation of dialectical behavior therapy skills training group for treatment-resistant depression. Journal of Nervous and Mental Disease, 196(2), 136-143.',
      _doi('10.1097/NMD.0b013e318162aa3f')),
  CourseSource(
      'neff2003',
      CourseSourceKind.review,
      'Neff K.D. (2003). Self-compassion: an alternative conceptualization of a healthy attitude toward oneself. Self and Identity, 2(2), 85-101.',
      _doi('10.1080/15298860309032')),
  CourseSource(
      'ferrari2019',
      CourseSourceKind.review,
      'Ferrari M. et al. (2019). Self-compassion interventions and psychosocial outcomes: a meta-analysis of RCTs. Mindfulness, 10, 1455-1473.',
      _doi('10.1007/s12671-019-01134-6')),
  // Relapse prevention and safety
  CourseSource(
      'kuyken2016',
      CourseSourceKind.review,
      'Kuyken W. et al. (2016). Efficacy of mindfulness-based cognitive therapy in prevention of depressive relapse: an individual patient data meta-analysis from randomized trials. JAMA Psychiatry, 73(6), 565-574.',
      _doi('10.1001/jamapsychiatry.2016.0076')),
  CourseSource(
      'stanley2012',
      CourseSourceKind.trial,
      'Stanley B., Brown G.K. (2012). Safety Planning Intervention: a brief intervention to mitigate suicide risk. Cognitive and Behavioral Practice, 19(2), 256-264.',
      _doi('10.1016/j.cbpra.2011.01.001')),
];
