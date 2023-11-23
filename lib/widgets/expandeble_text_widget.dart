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
            ellipsis: '..."',
            text: textSpan,
            maxLines: widget.maxLines,
            textDirection: TextDirection.ltr,
          );

          textPainter.layout(
              minWidth: 0,
              maxWidth: size.width,);
          //final list = textPainter.computeLineMetrics().first.descent
          print(textSpan.text!);

          if (textPainter.didExceedMaxLines && hidden) {
            return Container(
              child: Column(
                children: [

                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 1),
                      child: CustomPaint(painter: MyPainter(text: widget.text, maxLines: widget.maxLines, textStyle: widget.textStyle, ), size: Size(size.width - 60, 50),)),
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
                Text('"${widget.text}"', style: widget.textStyle ?? AppStyle.txtSFProDisplayLight16Gray,),
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



class MyPainter extends CustomPainter {
final String text;
final int maxLines;
final TextStyle? textStyle;

  MyPainter({required this.text, required this.maxLines, this.textStyle});
@override
  void paint(Canvas canvas, Size size) {
    final textSpan = TextSpan(text: '"${text}', style: textStyle?? AppStyle.txtSFProDisplayLight16Gray);
    final textPainter = TextPainter(
      ellipsis: '..."',
      text: textSpan,
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    final xCenter = (size.width - textPainter.width) / 2;
    final yCenter = (size.height - textPainter.height) / 2;
    final offset = Offset(xCenter, yCenter);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}