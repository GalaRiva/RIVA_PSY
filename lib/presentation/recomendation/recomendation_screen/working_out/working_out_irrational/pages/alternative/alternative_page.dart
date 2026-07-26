import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/utils/date_extension.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/bloc/cubit.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/bloc/state.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/pages/alternative/alternative_pdf.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/widgets/counter_of_spent_records_widet.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/widgets/record_card.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/expandeble_text_widget.dart';
import 'package:riva_psy/widgets/pdf_viewer_widget.dart';

import '../../../bloc/cubit.dart';

class AlternativePage extends StatelessWidget {

  final double widthOneCell = (size.width - 40) / 7;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkingOutIrrationalCubit>();
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            if (cubit.state.dayEventModel != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RecordCard(
                  mode: StandardRecordCardMode(cubit.state.dayEventModel!),
                  dataType: RecordCardDataType.Thought,
                  image: AspectRatio(
                    aspectRatio: 300 / 72,
                    child: Image.asset(
                      ImageConstant.alternativeWorkingOutImg,
                      fit: BoxFit.fill,
                      color: ColorConstant.cyan700.withOpacity(0.35),
                      colorBlendMode: BlendMode.overlay,
                    ),
                  ),
                  onButtonTap: () =>
                      cubit
                          .goToNextState(
                          WorkingOutIrrationalStage.challengeThought),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CustomButton(
                width: size.width > 320 ? 295 : size.width - 60,
                text: 'back'.tr().toUpperCase(),
                variant: ButtonVariant.White24,
                onTap: () => context.read<WorkingOutIrrationalCubit>().goToNextState(WorkingOutIrrationalStage.initialStage),
              ),
            ),
            CounterOfSpentRecordsWidget(
                workingOutQuantity: cubit.workingOutEventsLength(),
                notWorkingOutQuantity: cubit.allNegativeDayEventsLength()),
            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${cubit.dateStart.day.timeFormatted()}.${cubit.dateStart
                      .month.timeFormatted()}.${cubit.dateStart.year}-${cubit
                      .dateEnd.day.timeFormatted()}.${cubit.dateEnd.month
                      .timeFormatted()}.${cubit.dateEnd.year}",
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: AppStyle.txtSFProDisplayLight12,
                ),
                InkWell(
                  onTap: () async {
                    final result = (await Navigator.pushNamed(
                        context, AppRoutes.working_out_calendar))
                    as Map<String, dynamic>;
                    if (result != null) {
                      DateTime start = result['start'];
                      DateTime end = result['end'];
                      cubit.dateStart = start;
                      cubit.dateEnd = end;
                    }
                    cubit.updatePage();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'change_time_period'.tr(),
                        style: AppStyle.txtSFProDisplayLight11Deeppurple600
                            .copyWith(fontSize: 15),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      CustomImageView(
                          svgPath: ImageConstant
                              .rightArrow,
                          height:
                          getVerticalSize(
                              10),
                          width:
                          getHorizontalSize(
                              5),
                          margin: getMargin(
                              bottom: 3))
                    ],
                  ),
                )
              ],
            ),
            Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Container(
                    margin: getMargin(top: 28),
                    width: getHorizontalSize(322),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: InkWell(
                        onTap: () =>
                            Navigator.push(context, MaterialPageRoute(builder: (
                                context) =>
                                PdfPreviewWidget(pdf: (format) async => AlternativePdf().makePdf(await cubit.getSpentRecordModels()),))),
                        child: Text(
                            '${'send_summary_report'.tr()} ${cubit.dateStart.day
                                .timeFormatted()}.${cubit.dateStart.month
                                .timeFormatted()}.${cubit.dateStart
                                .year}-${cubit.dateEnd.day
                                .timeFormatted()}.${cubit.dateEnd.month
                                .timeFormatted()}.${cubit.dateEnd.year}. pdf',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.txtSFProDisplayLight10
                                .copyWith(color: ColorConstant.cyan700,
                                fontSize: 14,
                                decorationColor:  ColorConstant.cyan700,
                                decoration: TextDecoration.underline)),
                      ),
                    ),
                  ),
                )),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Wrap(
                direction: Axis.vertical,
                spacing: 5,
                children: [
                  Wrap(
                    spacing: 5,
                    children: [
                      Container(
                        color: Colors.white,
                        width: 45, height: 30,
                        child: Center(
                          child: Text('date'.tr(), style: AppStyle
                              .txtSFProDisplayLight11Gray800, overflow: TextOverflow
                              .ellipsis,),
                        ),),
                      Container(
                        color: Colors.white,
                        width: 145, height: 30,
                        child: Center(
                          child: Text('alternative_thoughts'.tr(), style: AppStyle
                              .txtSFProDisplayLight11Gray800, overflow: TextOverflow
                              .ellipsis,),
                        ),),
                      Container(
                        color: Colors.white,
                        width: 145, height: 30,
                        child: Center(
                          child: Text('alternative_actions'.tr(), style: AppStyle
                              .txtSFProDisplayLight11Gray800, overflow: TextOverflow
                              .ellipsis,),
                        ),),
                    ],),
                  Wrap(
                    spacing: 5,
                      children: List.generate(7, (index) =>
                          Container(
                              color: Colors.white,
                              width: 45, height: 30,),)
                  ),
                  if(cubit.workingOutEventsLength() > 0)
                  Padding(padding: EdgeInsets.symmetric(vertical: 35),
                  child: Container(
                    width: size.width - 30,
                    color: Colors.white.withOpacity(0.48),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${'alternative'.tr()} ${cubit.lastSpentRecordModel().dayEventModel.date!.formatForRecord('dd.MM.yy')}', style: AppStyle.txtSFProDisplayLight16Gray,),
                              InkWell(
                                  onTap: cubit.redoSpentRecordModel,
                                  child: Text('redo'.tr(), style: AppStyle.txtSFProDisplayLight16Gray,)),

                            ],
                          ),
                          Padding(padding: EdgeInsets.only(top: 6, bottom: 10),
                          child: Divider(
                            indent: 0, endIndent: 0,
                            color: ColorConstant.grayTextColor,thickness: 1,
                          ),
                          ),
                          Text('alternative_thought'.tr(), style: AppStyle.txtSFProDisplayLight16Gray.copyWith(fontSize: 12),),
                          Padding(padding: EdgeInsets.symmetric(vertical: 15),
                          child: ExpandableTextWidget(text: '${cubit.lastSpentRecordModel().alternativeThoughts}', textStyle: AppStyle.txtSFProDisplayLight16Gray.copyWith(fontSize: 12), maxLines: 3,),

                          ),
                          Text('alternative_do'.tr(), style: AppStyle.txtSFProDisplayLight16Gray.copyWith(fontSize: 12),),
                          Padding(padding: EdgeInsets.only(top: 15),
                            child: ExpandableTextWidget(text: '${cubit.lastSpentRecordModel().alternativeDo}', textStyle: AppStyle.txtSFProDisplayLight16Gray.copyWith(fontSize: 12), maxLines: 3,),

                          ),


                        ],
                      ),
                    ),
                  ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }
}
