import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riva_psy/core/app_export.dart';

import '../../bloc/guided_journals_cubit.dart';
import '../../bloc/guided_journals_state.dart';
import '../../widgets/guided_journal_topic_card.dart';
import '../../widgets/scientific_basis_sheet.dart';

// Deliberately dark, same as "Проекция Я" (#0B1917) — an explicit exception
// to the app's light "quiet luxury" theme, needed so the dark forest cover
// artwork on each card doesn't fight a light page background.
const _kLibraryBg = Color(0xFF0B1917);

class GuidedJournalLibraryPage extends StatelessWidget {
  const GuidedJournalLibraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GuidedJournalsCubit>();
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
            return Padding(
              padding: getPadding(left: 16, right: 16, top: 40),
              child: Text(
                'guided_journal_empty_library'.tr(),
                textAlign: TextAlign.center,
                style: AppStyle.txtSFProDisplayLight14.copyWith(color: Colors.white.withOpacity(0.7)),
              ),
            );
          }
          return SingleChildScrollView(
            child: Padding(
              padding: getPadding(left: 16, right: 16, top: 4, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'guided_journal_library_intro'.tr(),
                    style: AppStyle.txtSFProDisplayLight14.copyWith(color: Colors.white.withOpacity(0.75)),
                  ),
                  SizedBox(height: getVerticalSize(20)),
                  ...state.topics.map((topic) => Padding(
                        padding: getPadding(bottom: 14),
                        child: GuidedJournalTopicCard(
                          title: topic.title,
                          imageUrl: topic.imageUrl,
                          onTap: () => cubit.selectTopic(topic),
                          onInfoTap: (topic.scientificBasis ?? '').trim().isEmpty
                              ? null
                              : () => ScientificBasisSheet.show(context, topic.scientificBasis!),
                        ),
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
