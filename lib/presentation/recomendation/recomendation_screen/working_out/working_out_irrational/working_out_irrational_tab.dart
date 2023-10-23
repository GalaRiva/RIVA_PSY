import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/core/user_data/user.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/pages/alternative/alternative_page.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/pages/alternative/alternative_record_page.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/pages/record/record_page.dart';
import 'package:listenmebaby71_s_application17/widgets/go_to_new_tariff_widget.dart';

import 'bloc/cubit.dart';
import 'bloc/state.dart';
import 'pages/challenge/challenge_page.dart';
import 'pages/initial_working_out/empty_initial_working_out_page.dart';
import 'pages/initial_working_out/initial_working_out_page.dart';

class WorkingOutIrrationalTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
      onWillPop: () async {
        context.read<WorkingOutIrrationalCubit>().goToPrevState(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: ColorConstant.gray200,
        body: BlocBuilder<WorkingOutIrrationalCubit, WorkingOutIrrationalState>(builder: (_, state) => body(state, context)),
      ),
    );
  }

  Widget body(Object? state, BuildContext context) {
    final cubit = context.read<WorkingOutIrrationalCubit>();
    if (!CurrentUser.tariffIsOrion())
      return GoToNewTariffWidget(
        goToFreeRecommendation: false,
      );
    state as WorkingOutIrrationalState;
    if (state.loading) {
      return Scaffold(
        body: Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: ColorConstant.cyan700,
            ),
          ),
        ),
      );
    }

    switch (state.stage) {
      case WorkingOutIrrationalStage.initialStage:
        return cubit.existMoreDontWorkingOutEvents()
            ? InitialWorkingOutPage()
            : EmptyInitialWorkingOutPage();
      case WorkingOutIrrationalStage.alternative:
        return AlternativePage();
      case WorkingOutIrrationalStage.challengeDo:
        return ChallengePage();
      case WorkingOutIrrationalStage.challengeThought:
        return ChallengePage();
      case WorkingOutIrrationalStage.alternativeDo:
        return AlternativeRecordPage();
      case WorkingOutIrrationalStage.alternativeThought:
        return AlternativeRecordPage();
      case WorkingOutIrrationalStage.recordDo:
        return RecordPage();
      case WorkingOutIrrationalStage.recordThought:
        return RecordPage();
      case WorkingOutIrrationalStage.gratitude:
        // TODO: Handle this case.
        break;
      case WorkingOutIrrationalStage.relax:
        // TODO: Handle this case.
        break;
      default:
        return Scaffold(
          body: Center(
            child: Text(
              'Неизвестная страница',
              style: AppStyle.txtSFProDisplayLight14
                  .copyWith(color: ColorConstant.cyan700),
            ),
          ),
        );
    }

    return Scaffold(
      body: Center(
        child: Text(
          'Неизвестная страница',
          style: AppStyle.txtSFProDisplayLight14
              .copyWith(color: ColorConstant.cyan700),
        ),
      ),
    );
  }
}
