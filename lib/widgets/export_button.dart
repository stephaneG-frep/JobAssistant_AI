import 'package:flutter/material.dart';

import '../services/pdf_export_service.dart';

class ExportButton extends StatelessWidget {
  const ExportButton({super.key, required this.title, required this.content, this.asText = false});

  final String title;
  final String content;
  final bool asText;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: asText ? 'Exporter en TXT' : 'Exporter en PDF',
      icon: Icon(asText ? Icons.text_snippet_outlined : Icons.picture_as_pdf_outlined),
      onPressed: () async {
        final service = PdfExportService();
        if (asText) {
          await service.exportText(title: title, content: content);
        } else {
          await service.exportPdf(title: title, content: content);
        }
      },
    );
  }
}
