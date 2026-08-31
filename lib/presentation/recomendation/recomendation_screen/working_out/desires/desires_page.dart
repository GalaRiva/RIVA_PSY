import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riva_psy/core/user_data/user.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/desires/bloc/bloc.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/desires/widgets/desire_report_page.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/desires/widgets/desire_stage_first_page.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/desires/widgets/desire_stage_second_page.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/desires/widgets/desire_stage_third_page.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/desires/widgets/initial_desire_page.dart';
import 'package:riva_psy/widgets/go_to_new_tariff_widget.dart';

class DesiresPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(create: (_) {
        return DesiresBloc();
      }, child: BlocBuilder<DesiresBloc, DesiresState>(
        builder: (context, state) {
          if (!CurrentUser.tariffIsOrion()) {
            return GoToNewTariffWidget(
              goToFreeRecommendation: false,
            );
          }
          return state.maybeWhen(orElse: () {
            return SingleChildScrollView(child: InitialDesirePage());
          }, createDesire1: (_) => SingleChildScrollView(child: DesireStageFirstPage(controller: _,)),
            createDesire2: (_) => SingleChildScrollView(child: DesireStageSecondPage(controller: _,)),
            createDesire3: () => SingleChildScrollView(child: DesireStageThirdPage()),
            initialIsNotEmpty: (desires, executed, inProcess,expired,) {
            return DesireReportPage(desires: desires, executed: executed, inProcess: inProcess, expired: expired);
            }
          );
        },
      ),),
    );
  }
}
