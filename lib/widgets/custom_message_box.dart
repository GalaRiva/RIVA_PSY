import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';

class CustomMessageBox extends StatelessWidget {
  final String title;
  final dynamic content;
  final double height;
  final VoidCallback? onPop;
  final bool canPop;
  const CustomMessageBox(
      {Key? key,
      required this.title,
      required this.content,
      this.height = 150,
      this.onPop, this.canPop = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        child: SizedBox(
          height: getVerticalSize(30 + height),
          width: getHorizontalSize(340),
          child: Column(
            children: [
              Container(
                width: getHorizontalSize(340),
                height: getVerticalSize(30),
                color: ColorConstant.cyan700,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: getPadding(left: 6),
                      child: Text(
                        title,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: ColorConstant.gray200,
                            fontSize: 13,

                            fontWeight: FontWeight.w300,
                            fontFamily: 'SF Pro Display'),
                      ),
                    ),
                        Visibility(
                          visible: canPop,
                          child: IconButton(
                              alignment: Alignment.center,
                              onPressed: () => onPop != null ? onPop!() : Navigator.pop(context),
                              icon: Icon(
                                Icons.close,
                                size: getSize(18),
                                color: Colors.white,
                              )),
                        )
                  ],
                ),
              ),
               Container(
                  width: getHorizontalSize(340),
                  height: getVerticalSize(height!),
                  color: Colors.white,
                  child: Center(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child:content is String
                        ? Padding(
                            padding: getPadding(all: 6),
                            child: Text(
                              content ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                  fontFamily: 'SF Pro Display'),
                            ),
                          )
                        : content ?? Container(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
