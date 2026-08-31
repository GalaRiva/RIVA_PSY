import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/bloc/happiness_in_focus_bloc.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/bloc/happiness_in_focus_state.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/ui/pages/after_working_out_page.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/ui/pages/initial_page.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/ui/pages/start_page.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/ui/pages/thoughts_page.dart';

import '../../../../../../core/user_data/user.dart';
import '../../../../../../core/utils/color_constant.dart';
import '../../../../../../widgets/go_to_new_tariff_widget.dart';
import '../../../controller.dart';

class HappinessInFocusPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      context.read<HappinessInFocusCubit>().goToPrevState(context);
      return false;
    },
    child:Container(
      color: ColorConstant.gray200,
      child:   SingleChildScrollView(
        child: BlocConsumer<HappinessInFocusCubit, HappinessInFocusState >(
            // Tells K70Screen to hide its top tab bar + bottom nav once
            // the user leaves the initial "start" screen — see
            // K70Controller.immersiveMode.
            listener: (context, state) {
              if (Get.isRegistered<K70Controller>()) {
                Get.find<K70Controller>().setImmersiveMode(
                    state.stage != HappinessInFocusStage.InitialHappinessInFocusState);
              }
            },
            builder: (context,state) {
              if (!CurrentUser.tariffIsOrion()) {
                return GoToNewTariffWidget(
                  goToFreeRecommendation: false,
                );
              }
              if(state.stage == HappinessInFocusStage.StartHappinessInFocusState)
                return HappinessInFocusStartPage();
              if(state.stage == HappinessInFocusStage.ThoughtsHappinessInFocusState)
                return HappinessInFocusThoughtsPage();
              if(state.stage == HappinessInFocusStage.AfterWorkingOutHappinessInFocusState)
                return HappinessInFocusAfterWorkingOutPage(cubit: context.read<HappinessInFocusCubit>());
              return HappinessInFocusInitialPage();

            },
          ),
      ),
      ),
    );
  }
}
