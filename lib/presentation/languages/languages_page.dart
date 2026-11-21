import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riva_psy/core/utils/color_constant.dart';
import 'package:riva_psy/presentation/languages/bloc/bloc.dart';
import 'package:riva_psy/theme/app_style.dart';
import 'package:riva_psy/theme/app_colors.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:flutter/services.dart';

class LanguagesPage extends StatelessWidget {

  const LanguagesPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // This screen is only ever reached by pushing from Settings (see
      // k6_screen.dart) — never the app's own root/first screen (first-run
      // language detection is automatic now, from the device locale, see
      // main.dart) — so there's always something to pop back to. It had no
      // visible way back, only the platform's own edge-swipe/hardware-back,
      // easy to miss. Same chevron used everywhere else in the app now.
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded, size: 32, color: ColorConstant.gray800),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocProvider(
        create: (BuildContext context) {
          return LanguagesBloc()..add(LanguagesEvent.fetch(context: context));
        },
        child: BlocConsumer<LanguagesBloc, LanguagesState>(
          // The language changes silently otherwise: say so, in the NEW
          // language (the listener runs after the locale is already set), and
          // mark the chosen language so it is clear which one is active.
          listenWhen: (prev, cur) => prev.selected != null && cur.selected != prev.selected,
          listener: (context, state) {
            HapticFeedback.lightImpact();
            final messenger = ScaffoldMessenger.of(context);
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.primary,
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              duration: const Duration(milliseconds: 2400),
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('${'language_changed'.tr()}: ${state.selected?.name ?? ''}',
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ));
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('select_language'.tr(), style: AppStyle.txtSFProDisplayLight16, textAlign: TextAlign.center,),
                  SizedBox(height: 60,),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: state.locales.map((e) {
                      final isCurrent = state.selected?.code == e.code;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            isCurrent
                                ? CustomButton(
                                    variant: ButtonVariant.Cyan,
                                    fontStyle: ButtonFontStyle.White16,
                                    bgColor: ColorConstant.cyan700,
                                    text: e.name.toUpperCase(),
                                    onTap: () => context
                                        .read<LanguagesBloc>()
                                        .add(LanguagesEvent.select(context: context, languageModel: e)),
                                  )
                                : CustomButton(
                                    text: e.name.toUpperCase(),
                                    onTap: () => context
                                        .read<LanguagesBloc>()
                                        .add(LanguagesEvent.select(context: context, languageModel: e)),
                                  ),
                            if (isCurrent)
                              const Padding(
                                padding: EdgeInsets.only(left: 18),
                                child: Icon(Icons.check_rounded, color: Colors.white, size: 22),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}
