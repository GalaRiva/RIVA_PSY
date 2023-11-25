import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/bloc/cubit.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/bloc/state.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/ui/record_text_button.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/widgets/record_card.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';

import '../../../../../../../../widgets/expandeble_text_widget.dart';
import '../../bloc/cubit.dart';
import '../../bloc/state.dart';
import '../working_out_widget.dart';

class ChallengePage extends WorkingOutWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkingOutIrrationalCubit>();
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(15.0),
              child: RecordCard(
                onButtonTap: () => cubit.goToNextState(
                    cubit.state.stage == WorkingOutIrrationalStage.challengeThought
                        ? WorkingOutIrrationalStage.recordThought
                        : WorkingOutIrrationalStage.recordDo),
                mode: StandardRecordCardMode(cubit.selectedDayEventModel!),
                dataType:
                    cubit.state.stage == WorkingOutIrrationalStage.challengeThought
                        ? RecordCardDataType.Thought
                        : RecordCardDataType.Do,
              )),
          SizedBox(height: 50,)

        ],
      ),
    );
  }

  @override
  WorkingOutIrrationalStage stage() =>
      WorkingOutIrrationalStage.challengeThought;
}
