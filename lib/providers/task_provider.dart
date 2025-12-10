import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';

final supabaseClientProvider = Provider((ref) => Supabase.instance.client);

final taskListProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return TaskNotifier(client);
});

class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final SupabaseClient client;

  TaskNotifier(this.client) : super(const AsyncValue.loading()) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }
      final response = await client.from('tasks').select().eq('user_id', user.id);
      final tasks = response.map((json) => Task.fromJson(json)).toList();
      state = AsyncValue.data(tasks);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await client.from('tasks').insert(task.toJson());
      _loadTasks(); // Refresh list
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTask(Task updatedTask) async {
    try {
      await client.from('tasks').update(updatedTask.toJson()).eq('id', updatedTask.id);
      _loadTasks();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await client.from('tasks').delete().eq('id', taskId);
      _loadTasks();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleComplete(Task task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted, completedAt: !task.isCompleted ? DateTime.now() : null);
    await updateTask(updated);
  }
}
