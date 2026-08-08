import 'package:flutter/material.dart';

import '../../../../core/utils/color_constant.dart';
import '../../../../widgets/custom_message_box.dart';
import 'widgets/message_box_with_central_icon.dart';
import '../../../theme/app_colors.dart';

class ConcretePillScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final data = (ModalRoute.of(context)?.settings.arguments!) as Map;
    final _time = data['time'] ?? '';
    final _pillName = data['pill'] ?? '';
    final _date = data['date'] ?? DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: MessageBoxWithCentralIcon(_pillName, _time, context, _date).widget()
        ),
      ),
    );
  }
}
