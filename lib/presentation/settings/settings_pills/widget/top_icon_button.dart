import 'package:flutter/material.dart';
import 'package:riva_psy/theme/app_style.dart';

import '../../../../core/utils/color_constant.dart';

class TopIconButton extends StatelessWidget {
final Widget? icon;
final String title;
final Function()? onTap;

  const TopIconButton({Key? key, this.icon, required this.title, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                  color:
                  ColorConstant.fromHex('#5F6B80').withOpacity(0.2),
                  offset: Offset(0, 6),
                  blurRadius: 5)
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                icon ?? Container(),
                if(icon != null)
                  SizedBox(height: 10,),
                Text(title, style:  AppStyle.txtSFProDisplayLight16, textAlign: TextAlign.center,)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
