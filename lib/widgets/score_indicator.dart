import 'package:flutter/material.dart';

class ScoreIndicator extends StatelessWidget {
  const ScoreIndicator({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final value = score.clamp(0, 100) / 100;
    return Row(
      children: [
        SizedBox(width: 52, height: 52, child: CircularProgressIndicator(value: value, strokeWidth: 7)),
        const SizedBox(width: 12),
        Text('$score / 100', style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
