import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pattern.dart';
import '../models/task.dart';
import '../providers/pattern_provider.dart';
import '../providers/task_provider.dart';

Future<void> detectPatterns(WidgetRef ref) async {
  final tasks = ref.read(taskListProvider).value ?? [];
  if (tasks.isEmpty) return;

  // Group tasks by title
  Map<String, List<Task>> grouped = {};
  for (var task in tasks) {
    grouped.putIfAbsent(task.title, () => []).add(task);
  }

  final userId = Supabase.instance.client.auth.currentUser!.id;
  final client = Supabase.instance.client;

  for (var entry in grouped.entries) {
    final taskTitle = entry.key;
    final taskList = entry.value;
    final count = taskList.length;
    final lastDone = taskList.map((t) => t.createdAt).reduce((a, b) => a.isAfter(b) ? a : b);

    // Simple frequency detection
    String frequency = 'irregular';
    if (count >= 7) {
      frequency = 'daily';
    } else if (count >= 3) {
      frequency = 'weekly';
    } else if (count >= 1) {
      frequency = 'monthly';
    }

    // Check if pattern exists
    final patternId = '${taskTitle.hashCode}_$userId';
    final existingResponse = await client.from('patterns').select().eq('id', patternId).maybeSingle();

    if (existingResponse != null) {
      // Update existing pattern
      final existingPattern = Pattern.fromJson(existingResponse);
      final updated = existingPattern.copyWith(
        totalCount: count,
        lastDone: lastDone,
        frequency: frequency,
      );
      ref.read(patternListProvider.notifier).updatePattern(updated);
    } else {
      // Create new pattern
      final newPattern = Pattern(
        id: patternId,
        taskId: taskList.first.id,
        frequency: frequency,
        lastDone: lastDone,
        totalCount: count,
        userId: userId,
      );
      ref.read(patternListProvider.notifier).addPattern(newPattern);
    }
  }
}
