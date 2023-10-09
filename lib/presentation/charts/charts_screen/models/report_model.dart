import 'package:flutter/services.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/core/utils/date_extension.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

import '../../../../core/models/day_event_model.dart';

class ReportModel {
  List<String> _columnTags = ['Дата', 'Ситуация', 'Эмоции', 'Тело', 'Действия', 'Мысли'];
  List<double> _columnWeight = [79, 130, 130, 130, 130, 130];

  String _getTextFromEvent (int index, DayEventModel event){
    switch (index) {
      case 0:
        return event.date!.day.toString() + ' ' + event.date!.month.monthInText() + ' ' + event.date!.year.toString();
      case 1:
        return '${event.whatHappened!.name}\n${event.whereHappened!.name}\n${event.whoDidItHappen!.name}';
      case 2:
        String emotion = '';
        for(var item in  event.whatEmotion!) {
          emotion += '${item.name}\n';
        }
        return emotion.length > 50 ? emotion.substring(0, 50) + '...' : emotion + '\n(${event.emotionIntensity})';
      case 3:
        String bodyParts = '';
        for(var item in event.whatBodyParts!){
          bodyParts += '${item.bodyPartsModel.bodyPart}\n${item.subtitle}\n';
        }
        return bodyParts.length > 50 ? bodyParts.substring(0, 50) + '...' : bodyParts;
      case 4:
        final text = (event.whatIDo?.length ?? 0) > 40 ? event.whatIDo!.substring(0, 40) + '...' : event.whatIDo ?? '';
        return text;
      default:
        final text = (event.firstThoughts?.length ?? 0) > 40 ? event.firstThoughts!.substring(0, 40) + '...' : event.firstThoughts ?? '';
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
  Future<Uint8List> makePdf(List<DayEventModel> events) async {
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

    List<List<DayEventModel>> eventsInMatrix = [[]];
    print(events.length);
    for(int i = 0; i < events.length; i++) {
      if(i != 0) {
        if (i % 4 == 0 && eventsInMatrix.length > 2)
          eventsInMatrix.add([]);
        else if (i % 3 == 0 && eventsInMatrix.length < 2)
          eventsInMatrix.add([]);
      }
      eventsInMatrix[eventsInMatrix.length - 1].add(events[i]);
    }

    pdf.addPage(Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) {

      return Column(children: [
        SizedBox(
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
                margin: EdgeInsets.only(left: 426),
                  height: getVerticalSize(100),
                  width: getHorizontalSize(68),
                  child: Column(children: [
                    Image(imageQr,
                          height: getVerticalSize(65),
                          width: getVerticalSize(65),),
                    Text('СМЭР',
                        style: _textStyle.copyWith(
                            fontSize: 18, color: PdfColor.fromHex('#7f7f90'), fontWeight: FontWeight.bold
                        ))
                  ]))
            ],
          ),
        ),
        SizedBox(height: (39)),
        Row(children: List<Widget>.generate(6, (index) => Padding(padding: EdgeInsets.only(right: 3),
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

        SizedBox(height: 2),
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


  Widget _listEvents(List<DayEventModel> events) {
    return SizedBox(
        height: (100 * events.length.toDouble()),
        child : ListView.builder(itemBuilder: (context, index) {
          return Row(children: List<Widget>.generate(6, (_index) => Padding(padding: EdgeInsets.only(right: 3, bottom: 2),
              child:
              Container(
                  height: (98),
                  width: (_columnWeight[_index]),
                  decoration: BoxDecoration(
                      border: Border.all(color: _borderColor)
                  ),
                  child: Padding(
                      padding: EdgeInsets.only(top: 8, left: 5, right: 5, bottom: 8),
                      child: Text(_getTextFromEvent(_index, events[index]), style: _headerStyle.copyWith(), maxLines: 8)
                  )
              ))));
        }, itemCount: events.length > 3 ? 3 : events.length));
  }


}