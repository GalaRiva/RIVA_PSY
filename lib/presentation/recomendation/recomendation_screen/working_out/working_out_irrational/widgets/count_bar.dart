import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:listenmebaby71_s_application17/core/utils/color_constant.dart';

class CountBar extends StatelessWidget {
  final int currentCount;
  final int inTotalCount;
  const CountBar({Key? key, required this.currentCount, required this.inTotalCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Row(children: [
        Stack(
          children:[
            RatingBar.builder(
              itemSize: 9,
                glow: false,
                itemPadding: EdgeInsets.only(right: 5),
                itemCount: 5,
                initialRating: _calculate().toDouble(),
                unratedColor: ColorConstant.grayTextColor,
                itemBuilder: (_, __) {
                  return Container(width: 9,height: 9, decoration: BoxDecoration(color: ColorConstant.cyan700, shape: BoxShape.circle),);
                }, onRatingUpdate: (_){}),
          ]
        ),
        Container(width: 9, height: 9,
        child: CustomPaint(
          painter: OpenPainter(),
        ),
        )

      ],),
    );
  }

  int _calculate () {
    final percent =  (currentCount / inTotalCount) * 100;
    print(percent);
    return percent ~/ 20;
  }
}


class OpenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = ColorConstant.grayTextColor.withOpacity(0.8)
      ..style = PaintingStyle.fill
      ..strokeWidth = 0;
    //draw arc
    canvas.drawArc(Offset(0, 0) & Size(9, 9),
        pi / 2, //radians
        pi, //radians
        false,
        paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}