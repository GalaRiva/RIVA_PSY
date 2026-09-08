import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riva_psy/core/utils/color_constant.dart';
import 'package:riva_psy/presentation/languages/bloc/bloc.dart';
import 'package:riva_psy/theme/app_style.dart';
import 'package:riva_psy/widgets/custom_button.dart';

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
        child: BlocBuilder<LanguagesBloc, LanguagesState>(
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
                    children: state.locales.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: CustomButton(text: e.name.toUpperCase(), onTap: () => context.read<LanguagesBloc>().add(LanguagesEvent.select(context: context, languageModel: e)),),
                    )).toList(),
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
