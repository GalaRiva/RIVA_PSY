import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/user_data/user.dart';

import '../../bloc/guided_journals_cubit.dart';
import '../../bloc/guided_journals_state.dart';
import '../../models/guided_journal_topic.dart';
import '../../widgets/guided_journal_topic_card.dart';
import '../../widgets/scientific_basis_sheet.dart';
import '../paywall/guided_journal_paywall_page.dart';
import '../../../../../../../widgets/empty_state_widget.dart';

// Deliberately dark, same as "Проекция Я" (#0B1917) — an explicit exception
// to the app's light "quiet luxury" theme, needed so the dark forest cover
// artwork on each card doesn't fight a light page background.
const _kLibraryBg = Color(0xFF0B1917);

class GuidedJournalLibraryPage extends StatefulWidget {
  const GuidedJournalLibraryPage({Key? key}) : super(key: key);

  @override
  State<GuidedJournalLibraryPage> createState() => _GuidedJournalLibraryPageState();
}

class _GuidedJournalLibraryPageState extends State<GuidedJournalLibraryPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openTopic(BuildContext context, GuidedJournalTopic topic, bool locked) {
    if (locked) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const GuidedJournalPaywallPage()));
      return;
    }
    context.read<GuidedJournalsCubit>().selectTopic(topic);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _kLibraryBg,
      child: BlocBuilder<GuidedJournalsCubit, GuidedJournalsState>(
        builder: (context, state) {
          if (state.loading) {
            return Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(color: ColorConstant.cyan700),
              ),
            );
          }
          if (state.topics.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.auto_stories_rounded,
              title: 'guided_journal_empty_library'.tr(),
              dark: true,
              padding: getPadding(left: 16, right: 16, top: 40),
            );
          }

          final query = _query.trim().toLowerCase();
          // Keep each topic's real position in the full (unfiltered,
          // Firestore-ordered) list alongside it — that position, not its
          // index among the search results, decides whether it's free
          // (kGuidedJournalFreeTopicCount), so searching can never turn a
          // locked topic free just by changing how many results precede it.
          final visible = <MapEntry<int, GuidedJournalTopic>>[
            for (var i = 0; i < state.topics.length; i++)
              if (query.isEmpty || state.topics[i].title.toLowerCase().contains(query)) MapEntry(i, state.topics[i]),
          ];

          return SingleChildScrollView(
            child: Padding(
              padding: getPadding(left: 16, right: 16, top: 16, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'guided_journal_library_intro'.tr(),
                    style: AppStyle.txtSFProDisplayLight14.copyWith(color: Colors.white.withOpacity(0.75)),
                  ),
                  SizedBox(height: getVerticalSize(16)),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    style: AppStyle.txtSFProDisplayRegular14.copyWith(color: Colors.white),
                    cursorColor: ColorConstant.cyan700,
                    decoration: InputDecoration(
                      hintText: 'guided_journal_search_hint'.tr(),
                      hintStyle: AppStyle.txtSFProDisplayRegular14.copyWith(color: Colors.white.withOpacity(0.45)),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.55)),
                      suffixIcon: _query.isEmpty
                          ? null
                          : InkWell(
                              onTap: () => setState(() {
                                _searchController.clear();
                                _query = '';
                              }),
                              child: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.55)),
                            ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.07),
                      contentPadding: getPadding(left: 16, top: 12, right: 16, bottom: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: getVerticalSize(20)),
                  if (visible.isEmpty)
                    Padding(
                      padding: getPadding(top: 20),
                      child: Center(
                        child: Text(
                          'guided_journal_search_empty'.tr(),
                          textAlign: TextAlign.center,
                          style: AppStyle.txtSFProDisplayLight14.copyWith(color: Colors.white.withOpacity(0.55)),
                        ),
                      ),
                    ),
                  for (final entry in visible)
                    Padding(
                      padding: getPadding(bottom: 14),
                      child: GuidedJournalTopicCard(
                        title: entry.value.title,
                        imageUrl: entry.value.imageUrl,
                        locked: entry.key >= kGuidedJournalFreeTopicCount && !CurrentUser.tariffIsOrion(),
                        onTap: () => _openTopic(
                          context,
                          entry.value,
                          entry.key >= kGuidedJournalFreeTopicCount && !CurrentUser.tariffIsOrion(),
                        ),
                        onInfoTap: (entry.value.scientificBasis ?? '').trim().isEmpty
                            ? null
                            : () => ScientificBasisSheet.show(context, entry.value.scientificBasis!),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
