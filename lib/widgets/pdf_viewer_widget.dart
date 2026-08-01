import 'dart:async';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../presentation/charts/charts_screen/controller.dart';

class PdfPreviewWidget extends StatelessWidget {
  final FutureOr<Uint8List> Function(PdfPageFormat) pdf;
  const PdfPreviewWidget({Key? key, required this.pdf}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [PdfPreview(
          canChangeOrientation: false,
          canChangePageFormat: false,
          build: pdf
        ),
        Align(alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: 150),
          child: CustomButton(
            width: 120,
            text: 'back'.tr().toUpperCase(),
            bgColor: ColorConstant.whiteA700.withOpacity(0.4),

            onTap: () => Navigator.pop(context),
            padding: ButtonPadding.PaddingT8,
            prefixWidget: CustomImageView(
              margin: getMargin(right: 12),
              svgPath: ImageConstant.leftArrow,
            ),
          ),
        ),
        )
        ]
      ),
    );
  }
}