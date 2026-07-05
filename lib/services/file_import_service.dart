import 'dart:convert';

import 'package:file_picker/file_picker.dart';

class FileImportService {
  Future<String?> pickTextFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['txt', 'md'], withData: true);
    final file = result?.files.single;
    if (file == null) return null;
    final bytes = file.bytes;
    if (bytes != null) return utf8.decode(bytes);
    final path = file.path;
    if (path == null) return null;
    return null;
  }
}
