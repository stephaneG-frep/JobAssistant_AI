import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfExportService {
  Future<void> exportPdf({required String title, required String content}) async {
    final document = pw.Document();
    final sections = _splitSections(content);
    document.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(margin: pw.EdgeInsets.all(36)),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 14),
            decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blueGrey200))),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
                pw.SizedBox(height: 4),
                pw.Text('Généré avec JobAssistant AI • ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey500)),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          ...sections.map((section) => _section(section.$1, section.$2)),
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

  pw.Widget _section(String heading, String body) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (heading.isNotEmpty) pw.Text(heading, style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo700)),
          if (heading.isNotEmpty) pw.SizedBox(height: 5),
          pw.Text(body.trim(), style: const pw.TextStyle(fontSize: 11, lineSpacing: 3)),
        ],
      ),
    );
  }

  List<(String, String)> _splitSections(String content) {
    final lines = content.split('\n');
    final sections = <(String, String)>[];
    var heading = '';
    final buffer = StringBuffer();
    for (final line in lines) {
      final trimmed = line.trim();
      final looksLikeHeading = trimmed.length < 80 && (trimmed.endsWith(':') || RegExp(r'^\d+\.').hasMatch(trimmed) || trimmed == trimmed.toUpperCase());
      if (looksLikeHeading && buffer.isNotEmpty) {
        sections.add((heading, buffer.toString()));
        heading = trimmed.replaceAll(RegExp(r'^\d+\.\s*'), '').replaceAll(':', '');
        buffer.clear();
      } else if (looksLikeHeading && heading.isEmpty) {
        heading = trimmed.replaceAll(RegExp(r'^\d+\.\s*'), '').replaceAll(':', '');
      } else {
        buffer.writeln(line);
      }
    }
    if (buffer.isNotEmpty || sections.isEmpty) sections.add((heading, buffer.toString().trim().isEmpty ? content : buffer.toString()));
    return sections;
  }
}
