import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

class CustomIconButton extends StatelessWidget {
  CustomIconButton(
      {this.shape,
      this.padding,
      this.variant,
      this.alignment,
      this.margin,
      this.width,
      this.height,
      this.child,
      this.onTap});

  IconButtonShape? shape;

  IconButtonPadding? padding;

  IconButtonVariant? variant;

  Alignment? alignment;

  EdgeInsetsGeometry? margin;

  double? width;

  double? height;

  Widget? child;

  VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment ?? Alignment.center,
            child: _buildIconButtonWidget(),
          )
        : _buildIconButtonWidget();
  }

  _buildIconButtonWidget() {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: IconButton(
        visualDensity: VisualDensity(
          vertical: -4,
          horizontal: -4,
        ),
        iconSize: getSize(height ?? 0),
        padding: EdgeInsets.all(0),
        icon: Container(
          alignment: Alignment.center,
          width: getSize(width ?? 0),
          height: getSize(height ?? 0),
          padding: _setPadding(),
          decoration: _buildDecoration(),
          child: child,
        ),
        onPressed: onTap,
      ),
    );
  }

  _buildDecoration() {
    return BoxDecoration(
      color: _setColor(),
      border: _setBorder(),
      borderRadius: _setBorderRadius(),
    );
  }

  _setPadding() {
    switch (padding) {
      case IconButtonPadding.PaddingAll9:
        return getPadding(
          all: 9,
        );
      default:
        return getPadding(
          all: 4,
        );
    }
  }

  _setColor() {
    switch (variant) {
      case IconButtonVariant.FillWhiteA700:
        return ColorConstant.whiteA700;
      case IconButtonVariant.OutlineCyan700:
        return null;
      default:
        return ColorConstant.gray50;
    }
  }

  _setBorder() {
    switch (variant) {
      case IconButtonVariant.OutlineCyan700:
        return Border.all(
          color: ColorConstant.cyan700,
          width: getHorizontalSize(
            1.00,
          ),
        );
      case IconButtonVariant.Almost:
      case IconButtonVariant.FillWhiteA700:
        return null;
      default:
        return null;
    }
  }

  _setBorderRadius() {
    switch (shape) {
      case IconButtonShape.RoundedBorder21:
        return BorderRadius.circular(
          getHorizontalSize(
            21.00,
          ),
        );
      case IconButtonShape.CircleBorder11:
        return BorderRadius.circular(
          getHorizontalSize(
            11.00,
          ),
        );
      default:
        return BorderRadius.circular(
          getHorizontalSize(
            16.00,
          ),
        );
    }
  }
}

enum IconButtonShape {
  CircleBorder16,
  RoundedBorder21,
  CircleBorder11,
}
enum IconButtonPadding {
  PaddingAll4,
  PaddingAll9,
}
enum IconButtonVariant {
  Almost,
  FillWhiteA700,
  OutlineCyan700,
}
