import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/utils/date_extension.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../../../core/models/day_event_model.dart';

class ReportModel {
  List<String> _columnTags = ['date', 'situation', 'emotions', 'body', 'actions', 'thoughts'];
  List<double> _columnWeight = [79, 130, 130, 130, 130, 130];
  final String? text = null;

  String _getTextFromEvent (int index, DayEventModel event){

    switch (index) {
      case 0:
        return event.date!.day.toString() + ' ' + event.date!.month.monthInText() + ' ' + event.date!.year.toString();
      case 1:
        return  '${event.whatHappened!.localizedName}\n${event.whereHappened!.localizedName}\n${event.whoDidItHappen!.localizedName}';
      case 2:
        String emotion = '';
        for(var item in  event.whatEmotion!) {
          emotion += '${item.localizedName}\n';
        }
        // Was silently dropping the intensity whenever the text happened to
        // be truncated — the two are unrelated (truncation was cutting off
        // real content well before 50 characters), so both are kept now.
        return '$emotion(${event.emotionIntensity})';
      case 3:
        String bodyParts = '';
        for(var item in event.whatBodyParts!){
          bodyParts += '${item.bodyPartsModel.localizedBodyPart}\n${item.subtitle}\n';
        }
        return bodyParts;
      case 4:
        return event.whatIDo ?? '';
      default:
        return event.firstThoughts ?? '';
    }
  }

  final _headerStyle = TextStyle(
    color: PdfColor.fromHex('#3B3B4A'),
    fontSize: getFontSize(
      12,
    ),
  );


final _borderColor = PdfColor.fromInt(0xFFD7E1E1);
  Future<Uint8List> makePdf(List<DayEventModel> events) async {
    final imageLogo = MemoryImage(
        (await rootBundle.load(ImageConstant.pdfLogo)).buffer.asUint8List());
    final imageQr = MemoryImage(
        (await rootBundle.load(ImageConstant.pdfQR)).buffer.asUint8List());
    final imageText = MemoryImage(
        (await rootBundle.load(ImageConstant.pdfText)).buffer.asUint8List());
    final _textStyle = TextStyle(
      color: PdfColor.fromHex(text ?? '#3B3B4A'),
      fontSize: getFontSize(
        10,
      ),
    );

    final pdf = Document(
      theme: ThemeData.withFont(
        base: Font.ttf(await rootBundle.load('assets/fonts/RubikRegular.ttf')),
        bold: Font.ttf(await rootBundle.load('assets/fonts/RubikBold.ttf')),
    )
    );

    Widget brandingHeader() => SizedBox(
          height: getVerticalSize(100),
          child: Row(
            children: [
              SizedBox(
                  width: (239),
                  height: (77),
                  child: Row(children: [
                    SizedBox(
                        width: (79),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          SizedBox(
                              height: getSize(56),
                              width: getSize(56),
                              child: Image(imageLogo)),
                          SizedBox(height: getVerticalSize(6)),
                          SizedBox(
                              width: (79),
                              height: getVerticalSize(17),
                              child: Image(imageText, fit: BoxFit.contain)),
                        ])),

                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('mobile_application'.tr(),
                                  style: _textStyle, textAlign: TextAlign.left),
                          SizedBox(height: getVerticalSize(2)),
                          Text('rivapsy.com', style: _textStyle, textAlign: TextAlign.left),
                          SizedBox(height: getVerticalSize(23)),
                          Text(
                                  'convenient_and_free_record_and_send_SMER_to_psychologist'.tr(),
                                  style: _textStyle, textAlign: TextAlign.left),
                        ]),

                  ])),

              Container(
                margin: EdgeInsets.only(left: 426),
                  height: getVerticalSize(100),
                  width: getHorizontalSize(68),
                  child: Column(children: [
                    Image(imageQr,
                          height: getVerticalSize(65),
                          width: getVerticalSize(65),),
                    Text('SMER'.tr(),
                        style: _textStyle.copyWith(
                            fontSize: 18, color: PdfColor.fromHex('#7f7f90'), fontWeight: FontWeight.bold
                        ))
                  ]))
            ],
          ),
        );

    // Header row is marked repeat:true so pw.Table reprints it on every
    // page on its own — no more manually splitting `events` into pages.
    // Cells carry no border of their own — pw.Table measures each cell at
    // its own intrinsic size before it knows the shared row height, so a
    // per-cell Container border gets painted once at that (too-small) size
    // and again at the resolved row height, leaving a faint "ghost" box.
    // TableBorder on the Table itself (below) draws the grid after row
    // heights are settled, so there's only ever one line.
    TableRow columnHeaderRow() => TableRow(
          repeat: true,
          children: List<Widget>.generate(
            6,
            (index) => Container(
              height: (29),
              alignment: Alignment.center,
              child: Text(_columnTags[index].tr(), style: _headerStyle),
            ),
          ),
        );

    // Each cell sizes to fit its own text instead of a fixed height with a
    // hard maxLines cut — a short entry stays compact (more entries per
    // page), a long one just gets the room it actually needs, and pw.Table
    // (a SpanningWidget) carries rows over to a new page by itself.
    TableRow eventRow(DayEventModel event) => TableRow(
          children: List<Widget>.generate(
            6,
            (index) => Container(
              padding: const EdgeInsets.all(6),
              child: Text(_getTextFromEvent(index, event), style: _headerStyle),
            ),
          ),
        );

    pdf.addPage(MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      header: (context) =>
          context.pageNumber == 1 ? brandingHeader() : SizedBox(height: getVerticalSize(20)),
      build: (context) => [
        SizedBox(height: (2)),
        Table(
          border: TableBorder.all(color: _borderColor, width: 1),
          columnWidths: {
            for (var i = 0; i < _columnWeight.length; i++) i: FixedColumnWidth(_columnWeight[i]),
          },
          children: [
            columnHeaderRow(),
            ...events.map(eventRow),
          ],
        ),
      ],
    ));
    return pdf.save();
  }
}