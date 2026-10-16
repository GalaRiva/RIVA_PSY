import 'package:flutter/widgets.dart';

import '../core/services/notifications/reengagement_scheduler.dart';

// Invisible. Re-plans the local "come back" touches whenever the main screen
// is shown or the app returns to the foreground — see ReengagementScheduler.
class ReengagementHook extends StatefulWidget {
  const ReengagementHook({Key? key}) : super(key: key);

  @override
  State<ReengagementHook> createState() => _ReengagementHookState();
}

class _ReengagementHookState extends State<ReengagementHook> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => ReengagementScheduler.onAppActive());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ReengagementScheduler.onAppActive();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
