import 'package:flutter/widgets.dart';

import '../core/services/quick_action_service.dart';
import '../presentation/recomendation/recomendation_screen/working_out/programs/data/course_repository.dart';
import '../presentation/recomendation/recomendation_screen/working_out/programs/pages/situation_tool_screen.dart';

// Invisible, sits on the home screen next to ReengagementHook: when the app
// was opened from the icon shortcut "Хочется написать или проверить", it opens
// that tool of the program straight away (cold start and when resumed).
class QuickActionHook extends StatefulWidget {
  const QuickActionHook({Key? key}) : super(key: key);

  @override
  State<QuickActionHook> createState() => _QuickActionHookState();
}

class _QuickActionHookState extends State<QuickActionHook> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    final action = await QuickActionService.take();
    if (action != 'urge' || !mounted) return;
    final course = await CourseRepository().load('return_to_self');
    if (course == null || !mounted) return;
    final tools = course.tools.where((t) => t.id == 'contact').toList();
    if (tools.isEmpty) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => SituationToolScreen(course: course, tool: tools.first),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
