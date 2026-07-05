abstract class AiService {
  Future<String> generate(String prompt);
}

class AiUnavailableException implements Exception {
  AiUnavailableException(this.message);
  final String message;

  @override
  String toString() => message;
}
