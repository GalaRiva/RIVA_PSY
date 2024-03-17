import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/pages/gratitude/gratitude_page.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/widgets/record_card.dart';

import '../../bloc/cubit.dart';
import '../../bloc/state.dart';
import '../../widgets/relax_dialog/relax_dialog.dart';
import '../working_out_widget.dart';

class AlternativeRecordPage extends WorkingOutWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkingOutIrrationalCubit>();
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: RecordCard(
            onButtonTap: () {
              if(cubit.state.stage == WorkingOutIrrationalStage.alternativeThought)
              cubit.goToNextState(WorkingOutIrrationalStage.challengeDo);
              else {
                cubit.updateDayEvents();
                cubit.goToNextState(WorkingOutIrrationalStage.initialStage);

                if(cubit.spentRecordsToday >= 3) {
                  showDialog(
                      useSafeArea: false,
                      context: context, builder: (_) => RelaxDialog());
                }
              }
            },
            mode: AlternativeRecordCardMode(dayEventModel: cubit.state.dayEventModel!, spentRecordModel: cubit.state.spendRecordModel!, onRedoTap: () => cubit.goToNextState( cubit.state.stage == WorkingOutIrrationalStage.alternativeThought
                ? WorkingOutIrrationalStage.recordThought
                : WorkingOutIrrationalStage.recordDo)),
            dataType: cubit.state.stage == WorkingOutIrrationalStage.alternativeThought
                ? RecordCardDataType.Thought
                : RecordCardDataType.Do,
          )),
    );
  }

  @override
  WorkingOutIrrationalStage stage() =>
      WorkingOutIrrationalStage.alternativeThought;
}