import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/bloc/cubit.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/bloc/state.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import '../../../../../../../core/utils/size_utils.dart';
import '../../widgets/record_card.dart';

class RecordPage extends StatelessWidget {
  final String initWhyThisText;
  final String initAlternativeText;

  final whyThis = TextEditingController();
  final alternative = TextEditingController();

  String savedText = '';
  Timer? _debounce;

  RecordPage({Key? key, required this.initWhyThisText, required this.initAlternativeText}) : super(key: key){
    whyThis.text = initWhyThisText;
    alternative.text = initAlternativeText;
  }
  final scrollController = ScrollController();
  final whyThisFocusNode = FocusNode();

  void _autosaveWhyThis(WorkingOutIrrationalCubit cubit, bool isThought) {
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 1500), () {
      savedText = whyThis.text;
      if (isThought) {
        cubit.fillSpendRecordModel(whyThisThoughts: savedText);
      } else {
        cubit.fillSpendRecordModel(whyThisDo: savedText);
      }
      cubit.updateDayEvents(nextState: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkingOutIrrationalCubit>();
    final isThought =
        cubit.state.stage == WorkingOutIrrationalStage.recordThought;

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: RecordCard(
                mode: StandardRecordCardMode(cubit.selectedDayEventModel!),
                dataType:
                isThought
                        ? RecordCardDataType.Thought
                        : RecordCardDataType.Do,
                showShadow: false,
                // Was unwired — the button looked disabled (and was: no
                // onTap at all). It now does exactly what the field below
                // it is for: jump straight to writing the challenge.
                onButtonTap: () => FocusScope.of(context).requestFocus(whyThisFocusNode),
              ),
            ),
          ),
          Center(
            child: Container(
              width: size.width - 30,
              decoration: BoxDecoration(
                color: ColorConstant.cardShadow,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 29, bottom: 15),
                      child: Text(
                        isThought
                            ? 'why_i_think_that'.tr()
                            : 'why_i_do_that'.tr(),
                        style: AppStyle.txtSFProDisplayLight16,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 60,
                      child: TextFormField(
                        focusNode: whyThisFocusNode,
                        onTap: () => scrollController.animateTo(scrollController.offset + MediaQuery.of(context).viewInsets.bottom, duration: Duration(milliseconds: 500), curve: Curves.easeIn),
                        onChanged: (_) => _autosaveWhyThis(cubit, isThought),
                        controller: whyThis,
                        maxLines: 10,
                        minLines: 4,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(4, 8, 4, 8),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.zero,
                                borderSide: BorderSide.none),
                            fillColor: ColorConstant.grayLight,
                            filled: true,
                            hintText: '',
                            hintStyle: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                              color: ColorConstant.fromHex('#3B3B4A'),
                            )),
                      ),
                    ),
                    SizedBox(height: 27,),
                    Text(isThought ? 'alternative_thought'.tr().toUpperCase() : 'alternative_do'.tr().toUpperCase(), style: AppStyle.txtSFProDisplayLight16,),
                    Padding(padding: EdgeInsets.symmetric(vertical: 15),
                    child: AspectRatio(
                      aspectRatio: 300/220,
                      child: Container(
                        decoration: BoxDecoration(
                          //color: ColorConstant.darkWhite,
                          borderRadius: BorderRadius.circular(3)
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Image.asset(isThought ? ImageConstant.humanAlternativeImg : ImageConstant.humanAlternativeDoImg,),
                        ),
                      ),
                    ),
                    ),
                    Text(
                      isThought
                          ? 'i_with_i_could_think_about_it'.tr()
                          : 'which_my_behaviors'.tr(),
                      style: AppStyle.txtSFProDisplayLight16,
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 15),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 60,
                      child: TextFormField(
                        controller: alternative,
                        maxLines: 10,
                        minLines: 4,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(4, 8, 4, 8),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.zero,
                                borderSide: BorderSide.none),
                            fillColor: ColorConstant.grayLight,
                            filled: true,
                            hintText: '',
                            hintStyle: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                              color: ColorConstant.fromHex('#3B3B4A'),
                            )),
                      ),
                    ),
                    ),
                    CustomButton(
                      text: 'done'.tr().toUpperCase(),
                      width: size.width - 60,
                      height: 47,
                      onTap: () {
                        _debounce?.cancel();
                        savedText = whyThis.text;
                        if(isThought) {
                          cubit.fillSpendRecordModel(whyThisThoughts: savedText, alternativeThoughts: alternative.text);
                          cubit.goToNextState(WorkingOutIrrationalStage.alternativeThought);
                      } else {
                        cubit.fillSpendRecordModel(whyThisDo: savedText, alternativeDo: alternative.text);
                        cubit.goToNextState(WorkingOutIrrationalStage.alternativeDo);
                      }
                      cubit.updateDayEvents(nextState: false);

                      },
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 50,)
        ],
      ),
    );
  }
}
