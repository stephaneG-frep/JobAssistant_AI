import 'dart:convert';

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfExportService {
  Future<void> exportPdf({required String title, required String content}) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text(title)),
          pw.Paragraph(text: content),
        ],
      ),
    );
    await Printing.sharePdf(bytes: await document.save(), filename: '${_safeName(title)}.pdf');
  }

  Future<void> exportText({required String title, required String content}) async {
    await Printing.sharePdf(bytes: utf8.encode(content), filename: '${_safeName(title)}.txt');
  }

  Future<void> exportJson({required String title, required String json}) async {
    await Printing.sharePdf(bytes: utf8.encode(json), filename: '${_safeName(title)}.json');
  }

  String _safeName(String value) => value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'_+$'), '');
}
