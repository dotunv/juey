import 'package:flutter/material.dart';
import '../app/theme/color_schemes.dart';
import 'spark_badge.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final List<String> tagLabels;
  final bool completed;
  final bool recommended;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TaskCard({
    super.key,
    required this.title,
    this.tagLabels = const [],
    this.completed = false,
    this.recommended = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: title,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        opacity: 1,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          scale: 1,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceDark2, width: 1),
              ),
              padding: const EdgeInsets.all(12),
              child: Stack(
                children: [
                  // Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (completed)
                            Icon(Icons.check_circle, color: AppColors.accent.withOpacity(0.9), size: 20),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (tagLabels.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: -6,
                          children: tagLabels.take(3).map((t) => _TagPill(label: t)).toList(),
                        ),
                    ],
                  ),

                  // Spark badge
                  if (recommended)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: SparkBadge(size: 18, pulse: true),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  const _TagPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryDark),
      ),
    );
  }
}
