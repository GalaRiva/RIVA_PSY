import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/bloc/happiness_in_focus_bloc.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/bloc/happiness_in_focus_state.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/ui/pages/initial_page.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/ui/pages/start_page.dart';

import '../../../../../../core/user_data/user.dart';
import '../../../../../../core/utils/color_constant.dart';
import '../../../../../../widgets/go_to_new_tariff_widget.dart';

class HappinessInFocusPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.gray200,
      body:  BlocBuilder<HappinessInFocusCubit, HappinessInFocusState >(
        builder: (context,state) {
          if (!CurrentUser.tariffIsOrion()) {
            return SingleChildScrollView(
              child: GoToNewTariffWidget(
                goToFreeRecommendation: false,
              ),
            );
          }
          if(state.stage == HappinessInFocusStage.InitialHappinessInFocusState)
            return HappinessInFocusInitialPage();
          if(state.stage == HappinessInFocusStage.StartHappinessInFocusState)
            return HappinessInFocusStartPage();
        },
      ),
    );
  }
}
