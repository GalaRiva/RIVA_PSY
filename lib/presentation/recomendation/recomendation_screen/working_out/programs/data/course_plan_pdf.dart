import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/course.dart';
import 'course_progress_store.dart';

// "Мой план" as a PDF (for the person's own use or to show a specialist):
// the latest saved card of each plan type of the course, in order. Built and
// shared on the device only.
class CoursePlanPdf {
  static Future<bool> hasAnything(Course course) async {
    for (final t in course.planTypes) {
      if (await CourseProgressStore.latest(course.id, t) != null) return true;
    }
    return false;
  }

  static Future<void> share(Course course, {required String footer, required String title}) async {
    final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/RubikRegular.ttf'));
    final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/RubikBold.ttf'));
    final doc = pw.Document(theme: pw.ThemeData.withFont(base: regular, bold: bold));
    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
    const gray = PdfColor.fromInt(0xFF6B7280);
    const teal = PdfColor.fromInt(0xFF1499A1);

    final sections = <pw.Widget>[];
    for (final type in course.planTypes) {
      final card = await CourseProgressStore.latest(course.id, type);
      if (card == null) continue;
      CourseTask? task;
      for (final s in course.steps) {
        if (s.task.cardType == type) task = s.task;
      }
      if (task == null) continue;
      final rows = <pw.Widget>[];
      for (final f in task.fields) {
        final v = card.values[f.id] ?? '';
        if (v.isEmpty || v == '0') continue;
        rows.add(pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(f.label, style: const pw.TextStyle(fontSize: 9, color: gray)),
            pw.Text(v == '1' ? '✓' : v, style: const pw.TextStyle(fontSize: 12)),
          ]),
        ));
      }
      if (rows.isEmpty) continue;
      sections.add(pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 16),
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: const PdfColor.fromInt(0xFFD7E1E1)),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(task.title, style: pw.TextStyle(fontSize: 13, font: bold, color: teal)),
          pw.SizedBox(height: 8),
          ...rows,
        ]),
      ));
    }

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (_) => [
        pw.Text(course.title, style: pw.TextStyle(fontSize: 18, font: bold)),
        pw.SizedBox(height: 2),
        pw.Text('$title · $date', style: const pw.TextStyle(fontSize: 10, color: gray)),
        pw.SizedBox(height: 18),
        ...sections,
        pw.SizedBox(height: 10),
        pw.Text(footer, style: const pw.TextStyle(fontSize: 9, color: gray)),
      ],
    ));
    await Printing.sharePdf(bytes: await doc.save(), filename: 'riva_psy_my_plan.pdf');
  }
}
