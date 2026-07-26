import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/bloc/cubit.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/bloc/state.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/desires/desires_page.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/ui/happiness_in_focus_page.dart';
import 'package:riva_psy/widgets/go_to_new_tariff_widget.dart';

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

            // Defense-in-depth: WorkingOutIrrationalTab, HappinessInFocusPage
            // and DesiresPage each also gate themselves individually — this
            // container-level check is a second layer so a future tab added
            // here without its own gate still can't leak paid content (see
            // PROJECT_CONTEXT.md for the bug this replaced: DesiresPage had
            // no gate of its own and showContent was defined but unused).
            if (!cubit.showContent) {
              return GoToNewTariffWidget(
                goToFreeRecommendation: false,
              );
            }

            return Container(
              decoration: AppDecoration.fillGray200,
              width: size.width,
              child: Column(
                children: [
                  Padding(
                    padding: getPadding(top: 30),
                    child: SizedBox(
                      height: getVerticalSize(50),
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: TabBar(
                        dividerHeight: 0,
                        controller: cubit.tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.center,
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
                            text: 'work_out_irrational'.tr(),
                          ),
                          Tab(
                          text: 'prestige_in_focus'.tr(),
                        ),
                          Tab(
                            text: 'desires'.tr(),
                          ),
                        ],
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
                      ),
                          Padding(
                            padding: const EdgeInsets.only(top: 18),
                            child: HappinessInFocusPage(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 18),
                            child: DesiresPage(),
                          ),
                    ]),
                  )
                ],
              ),
            );
          }

    );
  }
}
