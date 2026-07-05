import 'package:flutter/material.dart';

class PromptInputBox extends StatelessWidget {
  const PromptInputBox({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.minLines = 5,
    this.action,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final int minLines;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: null,
          decoration: InputDecoration(labelText: label, hintText: hint, alignLabelWithHint: true),
        ),
        if (action != null) ...[
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerRight, child: action),
        ],
      ],
    );
  }
}
