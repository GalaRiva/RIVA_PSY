import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/desires/bloc/bloc.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_text_form_field.dart';

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
                  'desires_stage'.tr(args: ['1']),
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
              'write_what_you_wish'.tr().toUpperCase(),
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
              'most_simple_desires'.tr().toUpperCase(),
              style: AppStyle.txtSFProDisplayLight16,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'what_i_wish'.tr().toUpperCase(),
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
                    text: 'cancel'.tr().toUpperCase(),
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
                    text: 'save'.tr().toUpperCase(),
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
