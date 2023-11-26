import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../../../../core/utils/color_constant.dart';
import '../../../../../../../../core/utils/image_constant.dart';
import '../../../../../../../../theme/app_style.dart';
import '../../../../../../../../widgets/custom_button.dart';
import '../../cubit/cubit.dart';

class SuperQuestEndPage extends StatefulWidget {
  @override
  State<SuperQuestEndPage> createState() => _SuperQuestEndPageState();
}

class _SuperQuestEndPageState extends State<SuperQuestEndPage> {
  bool confirm = false;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SuperQuestCubit>();
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(15),
          child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: ColorConstant.gray200,
                  border: Border.all(color: Colors.white, width: 1)),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: SvgPicture.asset(
                        ImageConstant.imgCloseGray200,
                        width: 10,
                        height: 10,
                        color: ColorConstant.blueGray400,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: Center(
                        child: Text(
                      'Лучшая похвала и награда то, что ты уже получил, сделав это'
                          .toUpperCase(),
                      style: AppStyle.txtSFProDisplayLight16,
                    )),
                  ),
                  AspectRatio(
                    aspectRatio: 300 / 300,
                    child: Container(
                      color: ColorConstant.darkWhite,
                      padding: EdgeInsets.all(35),
                      child: AspectRatio(
                        aspectRatio: 230 / 230,
                        child: Image.asset(
                          ImageConstant.superQuestComplete,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                        child: GestureDetector(
                      onTap: () {
                        setState(() {
                          confirm = !confirm;
                        });
                      },
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorConstant.darkWhite),
                        child: Center(
                          child: SvgPicture.asset(
                            ImageConstant.okeyIcon,
                            color: cubit.state.confirm
                                ? ColorConstant.cyan700
                                : ColorConstant.gray200,
                            width: 50,
                          ),
                        ),
                      ),
                    )),
                  ),
                  CustomButton(
                    text: 'готово'.toUpperCase(),
                    variant: ButtonVariant.Cyan,
                    fontStyle: ButtonFontStyle.White16,
                    onTap: () {
                      cubit.completeSuperQuest();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ))),
    );
  }
}
