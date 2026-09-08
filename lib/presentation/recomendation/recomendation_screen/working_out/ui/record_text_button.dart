import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/models/day_event_model.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../../../../../widgets/second_variant_event_card.dart';

class RecordTextButton extends StatelessWidget {
  final Function? onTap;
  final DayEventModel dayEventModel;

  const RecordTextButton({Key? key, this.onTap, required this.dayEventModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          if (onTap != null)
            onTap!();
          else {
            showDialog(
                context: context,
                builder: (_) {
                  final _style = TextStyle(
                    color: ColorConstant.deepPurple600,
                    fontSize: getFontSize(
                      9,
                    ),
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w400,
                  );
                  return Center(
                    child: Container(
                      width: size.width - 30,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3)),
                      child: Container(
                        margin: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                            color: ColorConstant.gray300,
                            borderRadius: BorderRadius.circular(3)),
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${'diary_entry_label'.tr()} ${dayEventModel.date!.format(
                                'dd.MM.yy  hh:mm',
                              )}', style: AppStyle.txtSFProDisplayLight16Cyan700,),
                              SizedBox(
                                height: 30,
                              ),
                              _recordRow(title: 'diary_what_happened'.tr(), dayEventVariable: [Text(
                                dayEventModel.whatHappened!.localizedName,
                                style: _style,
                              )]),
                              _recordRow(title: 'diary_where_happened'.tr(), dayEventVariable: [Text(
                                dayEventModel.whereHappened!.localizedName,
                                style: _style,
                              )]),
                              _recordRow(title: 'diary_who_with'.tr(), dayEventVariable: [Text(
                                dayEventModel.whoDidItHappen!.localizedName,
                                style: _style,
                              )]),
                              _recordRow(title: 'diary_emotion_felt'.tr(), dayEventVariable: [
                                Text(
                                  dayEventModel.whatEmotion!.first.localizedName,
                                  style: _style,
                                ),
                                IgnorePointer(
                                  child: SleekCircularSlider(
                                    appearance: CircularSliderAppearance(
                                        animationEnabled: false,
                                        infoProperties: InfoProperties(
                                            topLabelText: '',
                                            mainLabelStyle: TextStyle(
                                                fontSize: 1,
                                                color: Colors.transparent)),
                                        startAngle: 105,
                                        angleRange: 330,
                                        size: 11,
                                        customColors: CustomSliderColors(
                                          trackColor: Colors.transparent,
                                          dotColor:
                                          Colors.transparent,
                                          progressBarColors: [
                                            ColorConstant.fromHex('#403875'),
                                            ColorConstant.fromHex('#7FBDBA'),
                                          ],
                                        ),
                                        customWidths: CustomSliderWidths(
                                            progressBarWidth: 2, trackWidth: 2)),
                                    min: 0,
                                    max: 10,
                                    initialValue:
                                    dayEventModel.emotionIntensity.toDouble(),
                                  ),
                                ),
                                Text(
                                  '(' + dayEventModel.emotionIntensity.toString() + ')',
                                  style: _style,
                                ),]),
                              _recordRow(title: 'diary_body_reaction'.tr(), dayEventVariable: [Text(
                                dayEventModel.whatBodyParts!.first.bodyPartsModel.localizedBodyPart,
                                style: _style,
                              )]),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text('diary_what_i_did'.tr(), style: AppStyle.txtSFProDisplayLight14Gray800,),
                              ),
                              Text('"${dayEventModel.whatIDo ?? ''}"', style: AppStyle.txtSFProDisplayLight14Gray800.copyWith(color: ColorConstant.fromHex('#7C8B88')), maxLines: 3, overflow: TextOverflow.ellipsis,),
                              _divider(),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text('diary_first_thoughts'.tr(), style: AppStyle.txtSFProDisplayLight14Gray800,),
                              ),
                              Text('"${dayEventModel.firstThoughts ?? ''}"', style: AppStyle.txtSFProDisplayLight14Gray800.copyWith(color: ColorConstant.fromHex('#7C8B88')), maxLines: 3, overflow: TextOverflow.ellipsis,),
                              SizedBox(height: 33,),
                              CustomButton(text: 'ok'.tr().toUpperCase(), onTap: () => Navigator.pop(context), height: 47, bgColor: Colors.white.withOpacity(0.44), fontStyle: ButtonFontStyle.DeepPurple16,)
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                });
          }
        },
        child: Row(
          children: [Text('${'diary_entry_label'.tr()} ${dayEventModel.date!.format('dd.MM.yy')}', style: AppStyle.txtSFProDisplayLight16Cyan700,), SizedBox(width: 5,) ,CustomImageView(
              svgPath: ImageConstant
                  .rightArrow,
              color: ColorConstant.cyan700,
              height:
              getVerticalSize(
                  8),
              width:
              getHorizontalSize(
                  4),
              margin: getMargin(
                  bottom: 3)),],
        ));
  }

  Widget _recordRow(
      {required String title, required List<Widget> dayEventVariable}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                flex: 4,
                child: Text(
                  title,
                  style: AppStyle.txtSFProDisplayLight14Gray800,
                )),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SecondVariantEventCard(
                      content: dayEventVariable,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        _divider()
      ],
    );
  }

  Widget _divider () {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Divider(
        indent: 0,
        endIndent: 0,
        thickness: 1,
        color: Colors.white,
      ),
    );
  }
}
