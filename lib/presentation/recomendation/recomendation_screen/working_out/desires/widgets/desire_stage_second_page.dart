import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/desires/bloc/bloc.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_text_form_field.dart';

import '../../../../../../core/utils/image_constant.dart';
import '../../../../../../theme/app_style.dart';

class DesireStageSecondPage extends StatelessWidget {
  final TextEditingController controller;

  const DesireStageSecondPage({Key? key, required this.controller})
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
                  'Желания 2/3',
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
              '''Какое именно и как именно? Опишите в деталях, если возможно, и максимально подробно.
Вкус, цвет, внешний вид, жареное, вареное, свежее, консистенция, свет, атмосфера, последовательность, ощущения, есть руками или сервировано по этикету- чем больше деталей, тем лучше!'''
                  .toUpperCase(),
              style: AppStyle.txtSFProDisplayLight12,
            ),
            SizedBox(
              height: 20,
            ),
            AspectRatio(
                aspectRatio: 300 / 200,
                child: Image.asset(
                  ImageConstant.desires2PNG,
                  fit: BoxFit.fill,
                )),
            SizedBox(
              height: 20,
            ),

            Text(
              '''Пример. Если любите яблоки, то какие именно, большие зеленые и кислосладкие у которых кожура гладкая, а при откусывании слышится хруст или маленькие красно-белые, сладкие и достаточно мягкие. Как именно Вы любите их есть: целиком, разрезая крупные или мелкие части, положив в тарелку или есть на ходу, смотря кино или после обеда?'''.toUpperCase(),
              style: AppStyle.txtSFProDisplayLight12,
            ),
            SizedBox(
              height: 20,
            ),
            CustomTextFormField(
              controller: controller,
              minLength: 6,
              maxLines: 10,
              color: ColorConstant.darkWhite,
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
                          .add(DesiresEvent.saveDetailsText());
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
