import 'package:flutter_test/flutter_test.dart';
import 'package:jobassistant_ai/services/prompt_builder_service.dart';

void main() {
  test('prompt builder keeps the truthful career guardrail', () {
    final prompt = PromptBuilderService().cvMatch('CV réel', 'Offre');

    expect(prompt, contains('sans inventer'));
    expect(prompt, contains('score de compatibilité'));
  });
}
