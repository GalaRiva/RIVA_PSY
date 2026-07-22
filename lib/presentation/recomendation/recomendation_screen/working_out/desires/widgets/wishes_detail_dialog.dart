import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/theme/app_style.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';

import '../../../../../../core/utils/color_constant.dart';

class WishesDetailDialog extends StatelessWidget {
  final int index;
  final Function()? onStart;
  final Function()? onNext;
   WishesDetailDialog({required this.index, this.onStart, this.onNext});

  final subtitles = ['','','','','Рекомендация для эффективности упражнения'];
  List<Widget> content (BuildContext context) => <Widget>[Text('''Начинается с простых вещей и чем больше практики, тем более глубоко Вы начинаете заглядывать и вырисовывать свой путь.

Пример: Я хочу сейчас яблоко, я хочу сейчас плакать, я хочу пить, я хочу послушать музыку.''',style: AppStyle.txtSFProDisplayLight12Gray800,), Text('''Какое именно?

Опишите в деталях. 

Если любите яблоки, то какие именно, большие зеленые и кислосладкие у которых кожура гладкая, а при откусывании слышится хруст или маленькие красно-белые, сладкие и достаточно мягкие. 

Как именно Вы любите их есть: целиком, разрезая крупные или мелкие части, положив в тарелку или есть на ходу?''', style: AppStyle.txtSFProDisplayLight12Gray800,),Text('''Вкусы и предпочтения могут меняться, появляться новые. Например, попробовали новое, поняли, что нравится и повторите в будущем - запишите''',style: AppStyle.txtSFProDisplayLight12Gray800,),Text('''Если сложно начать, вспомните и запишите то, что Вы любите и любили в детстве. 

Например, я люблю яблоки, мне нравится летом попасть под ливень, я люблю фотографировать''',style: AppStyle.txtSFProDisplayLight12Gray800,),Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
  Text('Поставь будильник через каждые 1-2 часа',style: AppStyle.txtSFProDisplayLight12Gray800,),
    SizedBox(height: 10,),
    Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Container(width: 148, color: ColorConstant.cyan700, height: 1,),
    ),
    SizedBox(height: 10,),
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('или',         style: AppStyle.txtSFProDisplayLight12Gray800),
        GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.reminders);
            },
            child: Text( ' напоминания в приложении\n',         style: AppStyle.txtSFProDisplayLight12Cyan700,)),
      ],
    ),

    Text.rich(TextSpan(
        style: AppStyle.txtSFProDisplayLight12Gray800,
        children: [
      TextSpan(text: '''для того, чтобы обратить внимание на себя и свои желания.  

Задавай себе вопрос: Что я хочу сейчас? Какую-нибудь мелочь здесь и сейчас. 

Я хочу пить/лечь/сесть/спать, рыбу, яблоко, фильм, книгу, - любое и какое именно. Если есть возможность сделайте это, удовлетворите своё желание.

'''),

    ]))
  ],)];

  final images = List.generate(5, (index) => 'assets/images/desires/desires_detail_${index + 1}.png');
  final ratios = [1/1, 3/2, 1/1, 1/1, 290/180];
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Material(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(3),
              color: ColorConstant.darkBg,
            ),
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(alignment: Alignment.topRight, child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: ColorConstant.blueGray400, size: 20,)),),
                SizedBox(height: 10,),
                Text('желания'.toUpperCase(), style: AppStyle.txtSFProDisplayLight16,),
                SizedBox(height: 10,),
                if(subtitles[index].isNotEmpty)
                  Padding(padding: EdgeInsets.only(bottom: 10), child: Text(
                      subtitles[index], style: AppStyle.txtSFProDisplayLight12Gray800,
                  ),),
                _buildImage(images[index], ratios[index]),
                SizedBox(height: 20,),

                content(context)[index],
                SizedBox(height: 20,),

                Row(children: [
                  Expanded(child: CustomButton(text: 'начать'.toUpperCase(), onTap: onStart,)),
                  SizedBox(width: 10,),
                  Expanded(child: CustomButton(text: 'далее'.toUpperCase(), onTap: onNext,)),

                ],)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage (String asset, double ratio) {
    return AspectRatio(aspectRatio: ratio,
    child: Image.asset(asset, fit: BoxFit.fill,),
    );
  }
}
