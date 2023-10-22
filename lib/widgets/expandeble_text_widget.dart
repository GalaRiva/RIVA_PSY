import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';


class ExpandableTextWidget extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final int maxLines;
  final TextStyle? textButtonStyle;

  const ExpandableTextWidget({Key? key, required this.text, this.textStyle, required this.maxLines, this.textButtonStyle}) : super(key: key);
  @override
  State<ExpandableTextWidget> createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {

  bool hidden = true;

    @override
    Widget build(BuildContext context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final textSpan = TextSpan(text: widget.text);
          final textPainter = TextPainter(
            text: textSpan,
            maxLines: widget.maxLines,
            textDirection: TextDirection.ltr,
          );


          textPainter.layout(maxWidth: constraints.maxWidth);

          if (textPainter.didExceedMaxLines && hidden) {
            return Container(
              child: Column(
                children: [
                  Text(widget.text, maxLines: widget.maxLines, style: widget.textStyle ?? AppStyle.txtSFProDisplayLight16Gray),
                  SizedBox(height: 10,),
                  Align(
                    alignment: Alignment.topCenter,
                    child: TextButton(onPressed: (){
                      setState(() {
                        hidden = !hidden;
                      });
                      }, child: Text(hidden ? 'Показать полностью' : 'Скрыть', style: widget.textButtonStyle ?? AppStyle.txtSFProDisplayLight14.copyWith(color: ColorConstant.cyan700),)),
                  )
                ],
              ),
            );
          }
          return Container(
            child: Column(
              children: [
                Text(widget.text, style: widget.textStyle ?? AppStyle.txtSFProDisplayLight16Gray,),
                SizedBox(height: 10,),
                if(textPainter.didExceedMaxLines)
                Align(
                  alignment: Alignment.topCenter,
                  child: TextButton(onPressed: (){
                    setState(() {
                      hidden = !hidden;
                    });
                  }, child: Text(hidden ? 'Показать полностью' : 'Скрыть', style: widget.textButtonStyle ?? AppStyle.txtSFProDisplayLight14.copyWith(color: ColorConstant.cyan700),)),
                )
              ],
            ),
          );
        },
      );
  }
}
