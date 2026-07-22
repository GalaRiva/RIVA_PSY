import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/widgets/exercises_tab_body.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/widgets/custom_tab_bar.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/bloc/cubit.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/bloc/happiness_in_focus_bloc.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/bloc/happiness_in_focus_state.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/ui/working_out_screen.dart';

import '../../../../core/utils/color_constant.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../theme/app_style.dart';
import '../../../../widgets/custom_bottom_bar.dart';
import '../../../widgets/custom_button.dart';
import 'controller.dart';
import 'working_out/working_out_irrational/bloc/cubit.dart';

class K70Screen extends StatefulWidget {
  const K70Screen({Key? key}) : super(key: key);

  @override
  State<K70Screen> createState() => _K70ScreenState();
}

class _K70ScreenState extends State<K70Screen> with TickerProviderStateMixin {
  final controller = Get.put(K70Controller());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final scroll  = ScrollController();

  @override
  Widget build(BuildContext context) {
    if(MediaQuery.of(context).viewInsets.bottom > 1) {
      debugPrint('animate');
      scroll.animateTo(scroll.offset+ MediaQuery.of(context).viewInsets.bottom, duration: Duration(milliseconds: 500), curve: Curves.easeIn);
    }

    final data = ModalRoute.of(context)?.settings.arguments as Map?;
    int initialTab = 0;

    if (data != null) {
      controller.currentTab = data['first'] ?? 0;
      controller.currentTabSecond = data['second'] ?? 0;
      initialTab = data['initialTab'] ?? 0;
    }
    if (data == null) {
      controller.currentTab = 0;
      controller.currentTabSecond = 0;
    }
    controller.init(this);

    controller.tabControllerSecond!.addListener(() {
      controller.currentTabSecond = controller.tabControllerSecond!.index;

      controller.update();
    });

    PageController pageController = PageController(initialPage: initialTab);

    return MultiBlocProvider(
      providers: [
        BlocProvider<WorkingOutCubit>(
          create: (_) => WorkingOutCubit(this),
        ),
        BlocProvider<WorkingOutIrrationalCubit>(
          create: (_) => WorkingOutIrrationalCubit()..init(),
        ),
        BlocProvider<HappinessInFocusCubit>(
            create: (_) => HappinessInFocusCubit()),
      ],
      child: Scaffold(
        body: SingleChildScrollView(
          controller: scroll,
          //physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: size.height - (MediaQuery.of(context).padding.bottom + MediaQuery.of(context).padding.top),
                child: SafeArea(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Padding(
                               padding: EdgeInsets.only(top: 10, left: 16),
                               child: Text(
                                 "Рекомендации и упражнения",
                                 overflow: TextOverflow.ellipsis,
                                 textAlign: TextAlign.left,
                                 style: AppStyle.txtSFProDisplayLight10Gray800,
                               ),
                             ),
                             Padding(
                               padding: EdgeInsets.only(
                                 top: 12,
                               ),
                               child: Divider(
                                 height: 1,
                                 thickness: 1,
                                 indent: 16,
                                 endIndent: 16,
                                 color: ColorConstant.gray50,
                               ),
                             ),
                             Padding(
                               padding: EdgeInsets.only(top: 14, left: 16),
                               child: Text(
                                 'Справится с эмоциями',
                                 style: AppStyle.txtH1,
                               ),
                             ),
                             Align(
                               alignment: Alignment.topCenter,
                               child: CustomButton(
                                 variant: ButtonVariant.Cyan,
                                 fontStyle: ButtonFontStyle.White16,
                                 text: 'Помощь при панике и аффекте',
                                 bgColor: ColorConstant.cyan700,
                                 width: size.width - 32,
                                 onTap: () {
                                   pageController.animateToPage(0,
                                       duration: Duration(milliseconds: 400),
                                       curve: Curves.easeIn);
                                   controller.tabController!.animateTo(2);
                                   controller.currentTab = 2;
                                   controller.tabControllerSecond!
                                       .animateTo(controller.panicTab);
                                   controller.currentTabSecond = controller.panicTab;
                                 },
                                 height: 37,
                               ),
                             ),
                             Expanded(
                               child: CustomTabBar(
                                 tabs: [
                                   ExercisesTabBody(controller: controller),
                                   WorkingOutScreen()
                                 ],
                                 labels: ['Справиться с эмоцией', 'Обретение'],
                                 controller: pageController,
                               ),
                             )
                           ],
                         ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom,)
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomBar(),
      ),
    );
  }
}
