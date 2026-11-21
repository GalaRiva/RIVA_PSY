import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/bloc/cubit.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/bloc/happiness_in_focus_bloc.dart';

import '../../../../theme/app_colors.dart';
import '../../../../widgets/custom_bottom_bar.dart';
import 'controller.dart';
import 'hub/practices_hub.dart';
import 'working_out/working_out_irrational/bloc/cubit.dart';

class K70Screen extends StatefulWidget {
  const K70Screen({Key? key}) : super(key: key);

  @override
  State<K70Screen> createState() => _K70ScreenState();
}

class _K70ScreenState extends State<K70Screen> with TickerProviderStateMixin {
  final controller = Get.put(K70Controller());
  Map? _deepLink;
  // Was all of this — reading route arguments, resetting
  // controller.currentTab/currentTabSecond, controller.init(this)
  // (recreating both TabControllers) — run directly in build(). Any
  // rebuild of this screen for *any* reason (a dialog opening elsewhere
  // and changing MediaQuery insets, a keyboard appearing, an unrelated
  // GetBuilder update bubbling up) re-ran it too, silently snapping the
  // tab selection back to whatever the route's original arguments said
  // (index 0 / "Введение" for routes with no arguments) even though the
  // user had since navigated to a different tab. Moved to
  // didChangeDependencies(), guarded to run exactly once, since that's
  // the correct one-time-per-route lifecycle hook that still has
  // ModalRoute.of(context) available (initState() doesn't reliably).
  bool _tabsInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tabsInitialized) return;
    _tabsInitialized = true;

    final data = ModalRoute.of(context)?.settings.arguments as Map?;
    if (data != null) {
      controller.currentTab = data['first'] ?? 0;
      controller.currentTabSecond = data['second'] ?? 0;
      controller.workingOutInitialTab = data['workingOutTab'];
    } else {
      controller.currentTab = 0;
      controller.currentTabSecond = 0;
    }
    controller.init(this);

    controller.tabControllerSecond!.addListener(() {
      controller.currentTabSecond = controller.tabControllerSecond!.index;
      controller.update();
    });

    _deepLink = data;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WorkingOutCubit>(
          create: (_) => WorkingOutCubit(this, initialTab: controller.workingOutInitialTab),
        ),
        BlocProvider<WorkingOutIrrationalCubit>(
          create: (_) => WorkingOutIrrationalCubit()..init(),
        ),
        BlocProvider<HappinessInFocusCubit>(create: (_) => HappinessInFocusCubit()),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        // "Практики" is a hub: one page, grouped by what a person needs.
        // Each block opens its area as a full screen (hub/). It used to be
        // a top tab bar with a second and third row of tabs inside it.
        body: SafeArea(child: PracticesHub(controller: controller, deepLink: _deepLink)),
        bottomNavigationBar: CustomBottomBar(),
      ),
    );
  }
}
