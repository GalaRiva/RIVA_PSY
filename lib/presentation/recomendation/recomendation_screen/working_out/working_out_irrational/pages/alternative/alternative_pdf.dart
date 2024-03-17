import 'package:flutter/services.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/core/utils/date_extension.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/models/spent_record_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';


class AlternativePdf {
  List<String> _columnTags = ['Дата', 'Альтернативные мысли', 'Альтернативные действия'];
  List<String> _secondColumnTags = [' ', 'Изначальная мысль', 'Почему я так подумал', 'Альтернативная мысль', 'Изначальное действие', 'Почему я так подумал', 'Альтернативное действие'];

  List<double> _columnWeight = [70, 340, 340];
  List<double> _secondColumnWeight = [70, 110, 110, 110, 110, 110, 110];

  String _getTextFromEvent (int index, SpentRecordModel event){
    switch (index) {
      case 0:
        return event.dayEventModel.date!.day.toString() + ' ' + event.dayEventModel.date!.month.monthInText() + ' ' + event.dayEventModel.date!.year.toString();
      case 1:
        final text = (event.dayEventModel.firstThoughts?.length ?? 0) > 40 ? event.dayEventModel.firstThoughts!.substring(0, 40) + '...' : event.dayEventModel.firstThoughts ?? '';
        return text;
      case 2:
        final text = (event.whyThisThoughts.length ?? 0) > 40 ? event.whyThisThoughts.substring(0, 40) + '...' : event.whyThisThoughts ?? '';
        return text;
      case 3:
        final text = (event.alternativeThoughts.length ?? 0) > 40 ? event.alternativeThoughts.substring(0, 40) + '...' : event.alternativeThoughts ?? '';
        return text;
      case 4:
        final text = (event.dayEventModel.whatIDo?.length ?? 0) > 40 ? event.dayEventModel.whatIDo!.substring(0, 40) + '...' : event.dayEventModel.whatIDo ?? '';
        return text;
      case 5:
        final text = (event.whyThisDo.length ?? 0) > 40 ? event.whyThisDo.substring(0, 40) + '...' : event.whyThisDo ?? '';
        return text;
    default:
        final text = (event.alternativeDo.length ?? 0) > 40 ? event.alternativeDo.substring(0, 40) + '...' : event.alternativeDo ?? '';
        return text;
    }
  }

  final _headerStyle = TextStyle(
    color: PdfColor.fromHex('#3B3B4A'),
    fontSize: getFontSize(
      12,
    ),
  );


  final _borderColor = PdfColor.fromInt(0xFFD7E1E1);
  Future<Uint8List> makePdf(List<SpentRecordModel> events) async {
    final imageLogo = MemoryImage(
        (await rootBundle.load(ImageConstant.pdfLogo)).buffer.asUint8List());
    final imageQr = MemoryImage(
        (await rootBundle.load(ImageConstant.pdfQR)).buffer.asUint8List());
    final imageText = MemoryImage(
        (await rootBundle.load(ImageConstant.pdfText)).buffer.asUint8List());
    final _textStyle = TextStyle(
      color: PdfColor.fromHex('#3B3B4A'),
      fontSize: getFontSize(
        10,
      ),
    );

    final pdf = Document(
        theme: ThemeData.withFont(
          base: await PdfGoogleFonts.rubikRegular(),
          bold: await PdfGoogleFonts.rubikBold(),
        )
    );

    List<List<SpentRecordModel>> eventsInMatrix = [[]];
    print(events.length);
    for(int i = 0; i < events.length; i++) {
      if(i > 1) {
        if ((i + 3) % 5 == 0)
          eventsInMatrix.add([]);

      }
      eventsInMatrix[eventsInMatrix.length - 1].add(events[i]);

    }
    print(eventsInMatrix.length);


    pdf.addPage(Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) {

          return Column(children: [
            Container(
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
                                      child: Image(imageText)),
                                ])),

                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Мобильное приложение',
                                  style: _textStyle, textAlign: TextAlign.left),
                              SizedBox(height: getVerticalSize(2)),
                              Text('rigelpsy.ru', style: _textStyle, textAlign: TextAlign.left),
                              SizedBox(height: getVerticalSize(23)),
                              Text(
                                  'Удобное и бесплатное ведение\nи отправка СМЭР психологу',
                                  style: _textStyle, textAlign: TextAlign.left),
                            ]),

                      ])),

                  Container(
                      margin: EdgeInsets.only(left: 234),
                      height: getVerticalSize(65),
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 230,
                            child: Text('АЛЬТЕРНАТИВНЫЕ МЫСЛИ И ДЕЙСТВИЯ',
                              textAlign: TextAlign.right,
                              style: _textStyle.copyWith(
                                  fontSize: 18, color: PdfColor.fromHex('#7f7f90'), fontWeight: FontWeight.bold
                              ), maxLines: 2, ),),


                        Image(imageQr,
                          height: getVerticalSize(65),
                          width: getVerticalSize(65),),
                      ]))
                ],
              ),
            ),
            SizedBox(height: (39)),
            Row(children: List<Widget>.generate(_columnTags.length, (index) => Padding(padding: EdgeInsets.only(right: 5),
                child:
                Container(
                    width: (_columnWeight[index]),
                    height: (29),
                    decoration: BoxDecoration(
                        border: Border.all(color: _borderColor)
                    ),
                    child: Center(
                        child: Text(_columnTags[index], style: _headerStyle.copyWith())
                    )
                )))),
            SizedBox(height: 5),
            Row(children: List<Widget>.generate(_secondColumnTags.length, (index) => Padding(padding: EdgeInsets.only(right: 5),
                child:
                Container(
                    width: (_secondColumnWeight[index]),
                    height: (29),
                    decoration: BoxDecoration(
                        border: Border.all(color: index == 0 ? PdfColors.white : _borderColor)
                    ),
                    child: Center(
                        child: Text(_secondColumnTags[index], style: _headerStyle.copyWith())
                    )
                )))),
            SizedBox(height: 5),
            _listEvents(eventsInMatrix[0])
          ]);
        }));
    if(eventsInMatrix.length > 1) {
      for(int i = 1; i < eventsInMatrix.length; i++) {
        pdf.addPage(Page(
            pageFormat: PdfPageFormat.a4.landscape,
            build: (context) => _listEvents(eventsInMatrix[i])));
      }
    }
    return pdf.save();
  }


  Widget _listEvents(List<SpentRecordModel> events) {
    return SizedBox(
        height: (100 * events.length.toDouble()),
        child : ListView.builder(itemBuilder: (context, index) {
          return Row(children: List<Widget>.generate(_secondColumnTags.length, (_index) => Padding(padding: EdgeInsets.only(right: 5, bottom: 5),
              child:
              Container(
                  height: (82),
                  width: (_secondColumnWeight[_index]),
                  decoration: BoxDecoration(
                      border: Border.all(color: _borderColor)
                  ),
                  child: Padding(
                      padding: EdgeInsets.only(top: 8, left: 5, right: 5, bottom: 8),
                      child: Text(_getTextFromEvent(_index, events[index]), style: _headerStyle.copyWith(), maxLines: 8)
                  )
              ))));
        }, itemCount: events.length > 5 ? 5 : events.length));
  }


}