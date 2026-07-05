import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class FileImportService {
  Future<String?> pickTextFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['txt', 'md', 'pdf', 'docx'], withData: true);
    final file = result?.files.single;
    if (file == null) return null;
    final bytes = file.bytes;
    if (bytes == null) return null;

    final extension = file.extension?.toLowerCase();
    if (extension == 'pdf') return _extractPdf(bytes);
    if (extension == 'docx') return _extractDocx(bytes);
    return utf8.decode(bytes, allowMalformed: true);
  }

  String _extractPdf(List<int> bytes) {
    final document = PdfDocument(inputBytes: bytes);
    final text = PdfTextExtractor(document).extractText();
    document.dispose();
    return text.trim();
  }

  String _extractDocx(List<int> bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final documentFile = archive.files.where((file) => file.name == 'word/document.xml').firstOrNull;
    if (documentFile == null) return '';
    final xml = utf8.decode(documentFile.content as List<int>, allowMalformed: true);
    return xml
        .replaceAll(RegExp(r'<w:p[^>]*>'), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n\s+'), '\n')
        .trim();
  }
}
