import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/core/utils/date_extension.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/bloc/cubit.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/bloc/state.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/pages/alternative/alternative_pdf.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/widgets/counter_of_spent_records_widet.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/widgets/record_card.dart';
import 'package:listenmebaby71_s_application17/widgets/pdf_viewer_widget.dart';

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
                  onButtonTap: () =>
                      cubit
                          .goToNextState(
                          WorkingOutIrrationalStage.challengeThought),
                ),
              ),
            CounterOfSpentRecordsWidget(
                workingOutQuantity: cubit.workingOutEventsLength(),
                notWorkingOutQuantity: cubit.dontWorkingOutEventsLength()),
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
                      cubit.emit(cubit.state);
                    }
                  },
                  child: Row(
                    children: [
                      Text(
                        'Изменить период времени',
                        style: AppStyle.txtSFProDisplayLight11Deeppurple600
                            .copyWith(fontSize: 15),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Image.asset(
                        ImageConstant.rightArrow,
                        width: 3,
                        height: 6,
                      )
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
                            'Отправить Сводный отчет ${cubit.dateStart.day
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
                          child: Text('Дата', style: AppStyle
                              .txtSFProDisplayLight11, overflow: TextOverflow
                              .ellipsis,),
                        ),),
                      Container(
                        color: Colors.white,
                        width: 145, height: 30,
                        child: Center(
                          child: Text('Альтернативные мысли', style: AppStyle
                              .txtSFProDisplayLight11, overflow: TextOverflow
                              .ellipsis,),
                        ),),
                      Container(
                        color: Colors.white,
                        width: 145, height: 30,
                        child: Center(
                          child: Text('Альтернативные действия', style: AppStyle
                              .txtSFProDisplayLight11, overflow: TextOverflow
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
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
