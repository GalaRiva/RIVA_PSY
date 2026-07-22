import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listenmebaby71_s_application17/presentation/languages/bloc/bloc.dart';
import 'package:listenmebaby71_s_application17/theme/app_style.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';

class LanguagesPage extends StatelessWidget {

  const LanguagesPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
