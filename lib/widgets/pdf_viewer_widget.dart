import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../presentation/charts/charts_screen/controller.dart';

class PdfPreviewWidget extends StatelessWidget {
  final FutureOr<Uint8List> Function(PdfPageFormat) pdf;
  const PdfPreviewWidget({Key? key, required this.pdf}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PdfPreview(
        canChangeOrientation: false,
        canChangePageFormat: false,
        build: pdf
      ),
    );
  }
}