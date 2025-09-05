import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/suggestion_provider.dart';
import '../services/pattern_detection_service.dart';
import '../services/notification_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(taskListProvider.notifier).deleteTask(task.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskListProvider);
    final suggestionAsync = ref.watch(suggestionListProvider);
    final reasons = ref.watch(suggestionReasonsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Juey'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('✨ Suggestions for You', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            suggestionAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error: $err'),
              data: (suggestions) => suggestions.isEmpty
                  ? const Text('No suggestions yet. Add tasks to see patterns!')
                  : SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = suggestions[index];
                          final task = taskAsync.value?.firstWhere((t) => t.id == suggestion.taskId);
                          return Dismissible(
                            key: Key(suggestion.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.close, color: Colors.white),
                            ),
                            onDismissed: (direction) => ref.read(suggestionListProvider.notifier).rejectSuggestion(suggestion.id),
                            child: Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: 16),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text('💡', style: TextStyle(fontSize: 24)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Suggested: ${task?.title ?? 'Unknown'}',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Confidence: ${(suggestion.confidence * 100).toInt()}%'),
                                      const SizedBox(height: 4),
                                      Text(
                                        reasons[suggestion.id] ?? '',
                                        style: const TextStyle(color: Colors.black54),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.check, color: Colors.green),
                                            onPressed: () => ref.read(suggestionListProvider.notifier).acceptSuggestion(suggestion.id),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close, color: Colors.red),
                                            onPressed: () => ref.read(suggestionListProvider.notifier).rejectSuggestion(suggestion.id),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            const Text('Your Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: taskAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (tasks) => tasks.isEmpty
                    ? const Center(child: Text('No tasks yet. Add one!'))
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Dismissible(
                            key: Key(task.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.green,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.check, color: Colors.white),
                            ),
                            onDismissed: (direction) => ref.read(taskListProvider.notifier).toggleComplete(task),
                            child: Card(
                              child: ListTile(
                                title: Text(task.title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (task.description != null) Text(task.description!),
                                    Text('Tags: ${task.tagIds.join(', ')}'), // Placeholder, need to resolve tag names
                                    Text('Created: ${task.createdAt.toLocal()}'),
                                    if (task.isCompleted) Text('Completed: ${task.completedAt?.toLocal()}'),
                                  ],
                                ),
                                trailing: Checkbox(
                                  value: task.isCompleted,
                                  onChanged: (value) => ref.read(taskListProvider.notifier).toggleComplete(task),
                                ),
                                onLongPress: () => _showDeleteDialog(context, ref, task),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.tag), label: 'Tags'),
          NavigationDestination(icon: Icon(Icons.pattern), label: 'Detect'),
          NavigationDestination(icon: Icon(Icons.lightbulb), label: 'Generate'),
          NavigationDestination(icon: Icon(Icons.notifications), label: 'Test'),
          NavigationDestination(icon: Icon(Icons.logout), label: 'Logout'),
        ],
        onDestinationSelected: (index) {
          if (index == 0) {
            context.go('/history');
          } else if (index == 1) {
            context.go('/tags');
          } else if (index == 2) {
            detectPatterns(ref);
          } else if (index == 3) {
            ref.read(suggestionListProvider.notifier).refreshTopSuggestions();
          } else if (index == 4) {
            NotificationService.showNotification('Juey Reminder', 'Time for your daily task!');
          } else if (index == 5) {
            Supabase.instance.client.auth.signOut();
          }
        },
      ),

      floatingActionButton: ScaleTransition(
        scale: _scaleAnimation,
        child: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            _animationController.forward().then((_) => _animationController.reverse());
            context.go('/add-task');
          },
        ),
      ),
    );
  }
}
