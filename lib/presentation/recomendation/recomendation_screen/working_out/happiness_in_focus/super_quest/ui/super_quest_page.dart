import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/super_quest/cubit/cubit.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/super_quest/cubit/state.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/super_quest/ui/pages/super_quest_end.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/super_quest/ui/pages/super_quest_middle_page.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/super_quest/ui/pages/super_quest_start_page.dart';

class SuperQuestPage extends StatelessWidget {
  const SuperQuestPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create:(_) => SuperQuestCubit(),
    child: WillPopScope(
      onWillPop: () async {
        context.read<SuperQuestCubit>().goToPrevState(context);
        return false;
      },
      child: BlocBuilder<SuperQuestCubit, SuperQuestState>(
        builder: (context, state) {
          if(state.stage == SuperQuestStage.start)
            return SuperQuestStartPage();
          if(state.stage == SuperQuestStage.middle)
            return SuperQuestMiddlePage();
          return SuperQuestEndPage();
        },
      ),
    ),

    );
  }
}
