import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/providers/language_provider.dart';
import 'package:provider/provider.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final List<String>? args;

  const CustomText(this.text,{Key? key,  this.style, this.textAlign, this.overflow, this.args}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  BlocBuilder<LanguageProvider, LangState>(
      builder: (context, state) {
        return Text(tr(text, args: args), style:style , textAlign: textAlign, overflow: overflow,);
      }
    );
  }

}
