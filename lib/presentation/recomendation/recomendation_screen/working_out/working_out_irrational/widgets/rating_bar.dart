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
                itemPadding: EdgeInsets.only(right: 5),
                itemCount: 5,
                glow: false,
                initialRating: 5,
                itemBuilder: (_, __) {
                  return Container(width: 9,height: 9, decoration: BoxDecoration(color: ColorConstant.grayTextColor, shape: BoxShape.circle),);
                }, onRatingUpdate: (_){}),
            RatingBar.builder(
              itemSize: 9,
                glow: false,
                itemPadding: EdgeInsets.only(right: 5),
                itemCount: 5,
                initialRating: _calculate().toDouble(),
                itemBuilder: (_, __) {
                  return Container(width: 9,height: 9, decoration: BoxDecoration(color: ColorConstant.cyan700, shape: BoxShape.circle),);
                }, onRatingUpdate: (_){}),
          ]
        ),
        SizedBox(
          width: 4.5,
          child: Stack(children: [
            Container(width: 9, height: 9,decoration: BoxDecoration(color: ColorConstant.grayTextColor.withOpacity(0.8), shape: BoxShape.circle))
          ],),
        )

      ],),
    );
  }

  int _calculate () {
    final percent =  (inTotalCount / 100) * currentCount;
    return percent ~/ 20;
  }
}
