import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/bloc/cubit.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/bloc/state.dart';

import '../../../../../core/utils/color_constant.dart';
import '../../../../../core/utils/size_utils.dart';
import '../../../../../theme/app_decoration.dart';
import '../working_out_irrational/working_out_irrational_tab.dart';

class WorkingOutScreen extends StatelessWidget {
  const WorkingOutScreen({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkingOutCubit, WorkingOutState>(
          builder: (BuildContext context, state) {
            final cubit = context.read<WorkingOutCubit>();

            return Container(
              decoration: AppDecoration.fillGray200,
              width: size.width,
              height: size.height - 271,
              child: Column(
                children: [
                  Padding(
                    padding: getPadding(top: 30),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: getVerticalSize(50),
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        child: TabBar(
                          controller: cubit.tabController,
                          isScrollable: true,
                          onTap: (val) async {
                            cubit.currentTab = val;
                          },
                          indicatorColor: ColorConstant.fromHex('#1499A1'),
                          unselectedLabelColor: ColorConstant.gray800,
                          labelStyle: TextStyle(
                            color: ColorConstant.gray800,
                            fontSize: getFontSize(
                              14,
                            ),
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w300,
                          ),
                          indicatorSize: TabBarIndicatorSize.label,
                          labelColor: ColorConstant.cyan700,
                          tabs: [
                            Tab(
                              text: 'Отработать иррациональное',
                            ),
                            /*Tab(
                            text: 'Престиж в фокусе- счастье',
                          ),*/
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                        controller: cubit.tabController,
                        children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: WorkingOutIrrationalTab(),
                      )
                    ]),
                  )
                ],
              ),
            );
          }

    );
  }
}
