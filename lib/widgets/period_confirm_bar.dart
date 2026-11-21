import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/theme/app_colors.dart';

// "Сохранить / Отмена" of the period pickers, pinned to the bottom of the screen
// so the way to confirm the chosen period is visible at once (it used to sit
// under the calendar, below the fold).
class PeriodConfirmBar extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;
  const PeriodConfirmBar({Key? key, required this.onSave, required this.onCancel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 18, offset: const Offset(0, -4))],
      ),
      padding: getPadding(left: 16, right: 16, top: 10, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                  shape: const StadiumBorder(),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('cancel'.tr(),
                      maxLines: 1, style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
          SizedBox(width: getHorizontalSize(10)),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('save'.tr(),
                      maxLines: 1, style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
