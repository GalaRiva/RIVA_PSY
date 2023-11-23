import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/bloc/cubit.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/bloc/state.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';

import '../../../../../../../core/utils/size_utils.dart';
import '../../widgets/record_card.dart';

class RecordPage extends StatelessWidget {
  final String initWhyThisText;
  final String initAlternativeText;

  final whyThis = TextEditingController();
  final alternative = TextEditingController();

  String savedText = '';

  RecordPage({Key? key, required this.initWhyThisText, required this.initAlternativeText}) : super(key: key){
    whyThis.text = initWhyThisText;
    alternative.text = initAlternativeText;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkingOutIrrationalCubit>();
    final isThought =
        cubit.state.stage == WorkingOutIrrationalStage.recordThought;

    return SingleChildScrollView(
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
                            ? 'Почему я так подумал? На основании чего я так решил? Где я слышал и/или от кого эти слова?'
                            : 'ПОЧЕМУ я так сделал? Почему именно такая реакция? Возможно, перенял эту модель или ранее был негативный опыт?',
                        style: AppStyle.txtSFProDisplayLight16,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 60,
                      child: TextFormField(
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
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                              color: ColorConstant.fromHex('#3B3B4A'),
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 11,
                    ),
                    CustomButton(
                      text: 'сохранить'.toUpperCase(),
                      onTap: () {savedText = whyThis.text;
                      if(isThought) {
                        cubit.fillSpendRecordModel(whyThisThoughts: savedText, );
                      } else {
                          cubit.fillSpendRecordModel(whyThisDo: savedText);
                      }
                      cubit.updateDayEvents(nextState: false);
                      },
                      height: 47,
                      width: size.width - 60,
                    ),
                    SizedBox(height: 27,),
                    Text(isThought ? 'Альтернативная мысль'.toUpperCase() : 'Альтернативное действие'.toUpperCase(), style: AppStyle.txtSFProDisplayLight16,),
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
                          ? 'Как бы я хотел подумать? Какая мысль более адекватная ситуации?Какие другие мысли могут быть в этой ситуации? Например, у авторитетного для Вас человека'
                          : '''Какое мое поведение более адекватно в этой ситуации? Как я хочу поступать в подобных ситуациях в будущем? Как я буду стараться реагировать и действовать в такой ситуации?''',
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
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                              color: ColorConstant.fromHex('#3B3B4A'),
                            )),
                      ),
                    ),
                    ),
                    CustomButton(
                      text: 'ГОТОВО',
                      width: size.width - 60,
                      height: 47,
                      onTap: () { if(isThought) {
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
