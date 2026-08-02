import 'package:flutter/material.dart';

enum StatusTone { positive, negative, neutral, warning }

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.tone});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final Color background;
    final Color foreground;
    switch (tone) {
      case StatusTone.positive:
        background = Colors.green.withOpacity(0.15);
        foreground = Colors.green.shade800;
        break;
      case StatusTone.negative:
        background = colors.errorContainer;
        foreground = colors.onErrorContainer;
        break;
      case StatusTone.warning:
        background = Colors.orange.withOpacity(0.18);
        foreground = Colors.orange.shade900;
        break;
      case StatusTone.neutral:
        background = colors.secondaryContainer;
        foreground = colors.onSecondaryContainer;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
