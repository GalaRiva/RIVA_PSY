import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/app_export.dart';

import '../../../../theme/app_style.dart';
import '../../../../widgets/custom_text_form_field.dart';
import '../../../../theme/app_icons.dart';

class RetractableContainerWidget extends StatefulWidget {
  final EdgeInsetsGeometry padding;
  final String title;
  final String? subtitle;
  final String hintText;
  final VoidCallback? update;
  final Widget Function(String) child;
  final TextEditingController textController;

  const RetractableContainerWidget(
      {Key? key,
      required this.padding,
      required this.title,
      this.subtitle,
      required this.hintText,
      required this.child,
      this.update,
      required this.textController})
      : super(key: key);

  @override
  State<RetractableContainerWidget> createState() =>
      _RetractableContainerWidgetState();
}

class _RetractableContainerWidgetState extends State<RetractableContainerWidget>
    with TickerProviderStateMixin {
  late AnimationController fadeController;
  late AnimationController slideController;
  late Animation<Offset> slideAnimation;

  bool wasTapped = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fadeController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: const Offset(0, 0.0),
    ).animate(CurvedAnimation(
      parent: slideController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    fadeController.dispose();
    slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: AppStyle.txtSFProDisplayLight16,
          ),
          Visibility(
              visible: widget.subtitle != null,
              child: Padding(
                padding: getPadding(top: 10),
                child: Text(widget.subtitle ?? '',
                    textAlign: TextAlign.left,
                    style: AppStyle.txtSFProDisplayLight12),
              )),
          Padding(
              padding: getPadding(left: 3, top: 16),
              child: Stack(alignment: Alignment.centerLeft, children: [
                IgnorePointer(
                  ignoring: !wasTapped,
                  child: CustomTextFormField(
                    focusNode: FocusNode(),
                    controller: widget.textController,
                    hintText: widget.hintText,
                    margin: getMargin(top: 16),
                    isObscureText: true,
                    maxLength: 26,
                    variant: TextFormFieldVariant.UnderLineWhiteA700,
                    counterText: '',
                    fontStyle: TextFormFieldFontStyle.SFProDisplayRegular14,
                    validator: (text) {
                      if (text!.trim() != "") {
                        if (text!.trim().length < 8) {
                          return 'password_length_min'.tr();
                        } else if (text!.trim().length > 26) {
                          return 'password_length_max'.tr();
                        } else if (!_isPasswordCompliant(text)) {
                          return 'password_complexity'.tr();
                        }
                      }
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () async {
                      if (wasTapped) {
                        fadeController.reverse();
                        slideController.reverse();
                        wasTapped = !wasTapped;
                      } else {
                        wasTapped = !wasTapped;
                        fadeController.forward();
                        slideController.forward();
                      }
                      widget.update!();
                    },
                    child: Padding(
                        padding: getPadding(bottom: 1),
                        child: wasTapped
                            ? Icon(
                                AppIcons.x,
                                color: ColorConstant.deepPurple600,
                                size: getVerticalSize(20),
                              )
                            : Text('change'.tr(),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle
                                    .txtSFProDisplayLight12Deeppurple600
                                    .copyWith(
                                        decoration: TextDecoration.underline))),
                  ),
                )
              ])),
          Visibility(
              visible: wasTapped,
              child: FadeTransition(
                  opacity: fadeController,
                  child: Padding(
                    padding: getPadding(top: 16),
                    child: SlideTransition(
                        position: slideAnimation,
                        child: widget.child(widget.textController.text)),
                  )))
        ],
      ),
    );
  }
}

bool _isPasswordCompliant(String password) {
  bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
  if (hasUppercase) {
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    if (hasDigits) {
      bool hasLowercase = password.contains(RegExp(r'[a-z]'));
      if (hasLowercase) {
        bool hasSpecialCharacters =
            password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
        return hasSpecialCharacters;
      }
    }
  }

  return false;
}
