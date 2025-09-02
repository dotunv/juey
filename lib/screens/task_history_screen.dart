import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/tag_provider.dart';

class TaskHistoryScreen extends ConsumerStatefulWidget {
  const TaskHistoryScreen({super.key});

  @override
  ConsumerState<TaskHistoryScreen> createState() => _TaskHistoryScreenState();
}

class _TaskHistoryScreenState extends ConsumerState<TaskHistoryScreen> {
  DateTime selectedDate = DateTime.now();
  List<String> selectedTagIds = [];

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskListProvider);
    final tagAsync = ref.watch(tagListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tag filter chips
          if (tagAsync.hasValue)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                children: tagAsync.value!
                    .map(
                      (tag) => FilterChip(
                        label: Text(tag.name),
                        selected: selectedTagIds.contains(tag.id),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedTagIds.add(tag.id);
                            } else {
                              selectedTagIds.remove(tag.id);
                            }
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          // Filtered tasks
          Expanded(
            child: taskAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (tasks) {
                final filteredTasks = _filterTasks(tasks);
                return ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return Dismissible(
                      key: Key(task.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                      onDismissed: (direction) => ref
                          .read(taskListProvider.notifier)
                          .toggleComplete(task),
                      child: Card(
                        child: ListTile(
                          title: Text(task.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (task.description != null)
                                Text(task.description!),
                              Text('Tags: ${task.tagIds.join(', ')}'),
                              Text('Created: ${task.createdAt.toLocal()}'),
                              if (task.isCompleted)
                                Text(
                                  'Completed: ${task.completedAt?.toLocal()}',
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditTaskDialog(context, task),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _showDeleteDialog(context, task),
                              ),
                            ],
                          ),
                          onTap: () => ref
                              .read(taskListProvider.notifier)
                              .toggleComplete(task),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Task> _filterTasks(List<Task> tasks) {
    return tasks.where((task) {
      final taskDate = task.createdAt.toLocal();
      final matchesDate =
          taskDate.year == selectedDate.year &&
          taskDate.month == selectedDate.month &&
          taskDate.day == selectedDate.day;
      final matchesTags =
          selectedTagIds.isEmpty ||
          task.tagIds.any((tagId) => selectedTagIds.contains(tagId));
      return matchesDate && matchesTags;
    }).toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);
    List<String> selectedTagIds = List.from(task.tagIds);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Select Tags:'),
              Wrap(
                children: ref
                    .watch(tagListProvider)
                    .maybeWhen(
                      data: (tags) => tags
                          .map(
                            (tag) => FilterChip(
                              label: Text(tag.name),
                              selected: selectedTagIds.contains(tag.id),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedTagIds.add(tag.id);
                                  } else {
                                    selectedTagIds.remove(tag.id);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                      orElse: () => [],
                    ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final updatedTask = task.copyWith(
                  title: titleController.text,
                  description: descController.text.isEmpty
                      ? null
                      : descController.text,
                  tagIds: selectedTagIds,
                );
                ref.read(taskListProvider.notifier).updateTask(updatedTask);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Task task) {
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
}
