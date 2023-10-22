import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/bloc/cubit.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/bloc/state.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/widgets/record_card.dart';

import '../../../bloc/cubit.dart';

class AlternativePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkingOutIrrationalCubit>();
    return SingleChildScrollView(
      child: Column(
        children: [
          if (cubit.state.dayEventModel != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: RecordCard(
                mode: StandardRecordCardMode(cubit.state.dayEventModel!),
                dataType: RecordCardDataType.Thought,
                image: AspectRatio(
                  aspectRatio: 300 / 72,
                  child: Image.asset(
                    ImageConstant.alternativeWorkingOutImg,
                    fit: BoxFit.fill,
                    color: ColorConstant.cyan700.withOpacity(0.35),
                  ),

                ),
                onButtonTap: () => cubit.goToNextState(WorkingOutIrrationalStage.challengeThought),
              ),
            )
        ],
      ),
    );
  }
}
