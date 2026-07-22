import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/desires/bloc/bloc.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_text_form_field.dart';

import '../../../../../../core/utils/image_constant.dart';
import '../../../../../../theme/app_style.dart';

class DesireStageFirstPage extends StatelessWidget {
  final TextEditingController controller;

  const DesireStageFirstPage({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.white, width: 1)),
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Желания 1/3',
                  style: AppStyle.txtSFProDisplayLight16,
                ),
                Text(
                  DateFormat('dd.MM.yy').format(DateTime.now()),
                  style: AppStyle.txtSFProDisplayLight16,
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 26,
                  height: 1,
                  color: Colors.white,
                ),
                Container(
                  width: 26,
                  height: 1,
                  color: Colors.white,
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '''Напиши, что ты хочешь сейчас? Здесь и сейчас.
Пить, поспать, лечь, сесть, почесать руку, сходить в туалет или посмотреть фильм, чай, яблоко, книга с приглушенным уютным светом и т.д. )'''
                  .toUpperCase(),
              style: AppStyle.txtSFProDisplayLight12,
            ),
            AspectRatio(
                aspectRatio: 300 / 111,
                child: Image.asset(
                  ImageConstant.desires1PNG,
                  fit: BoxFit.fill,
                )),
            SizedBox(
              height: 20,
            ),
            Text(
              'Самые простые желания'.toUpperCase(),
              style: AppStyle.txtSFProDisplayLight16,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              '''“Что я хочу сейчас?” или Что я люблю?'''.toUpperCase(),
              style: AppStyle.txtSFProDisplayLight12,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20,
            ),
            CustomTextFormField(
              color: ColorConstant.darkWhite,
              controller: controller,
              minLength: 6,
              maxLines: 10,
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'ОТМЕНА',
                    onTap: () {
                      context.read<DesiresBloc>().add(DesiresEvent.cancel());
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: CustomButton(
                    text: 'СОХРАНИТЬ',
                    onTap: () {
                      context
                          .read<DesiresBloc>()
                          .add(DesiresEvent.saveDesiresText());
                    },
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
