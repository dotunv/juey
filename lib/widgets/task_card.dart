import 'package:flutter/material.dart';
import '../models/task.dart';
import 'spark_badge.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.tagLabels,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleComplete,
    this.recommended = false,
  });

  final Task task;
  final List<String> tagLabels;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggleComplete;
  final bool recommended;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedScale(
      scale: 1,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: 1,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Checkbox(
                            value: task.isCompleted,
                            onChanged: (_) => onToggleComplete(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (task.description != null && task.description!.isNotEmpty)
                        Text(
                          task.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.7)),
                        ),
                      const Spacer(),
                      if (tagLabels.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: -6,
                          children: [
                            for (final label in tagLabels)
                              Chip(
                                label: Text(label),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (recommended)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Semantics(
                      label: 'Recommended task',
                      child: const SparkBadge(size: 18, shimmer: true),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
