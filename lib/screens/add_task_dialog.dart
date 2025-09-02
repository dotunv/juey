import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tag.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class AddTaskDialogContent extends StatefulWidget {
  final WidgetRef ref;
  final List<Tag> tags;
  const AddTaskDialogContent({required this.ref, required this.tags, super.key});

  @override
  _AddTaskDialogContentState createState() => _AddTaskDialogContentState();
}

class _AddTaskDialogContentState extends State<AddTaskDialogContent> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  List<String> selectedTagIds = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: descController,
            decoration: const InputDecoration(labelText: 'Description (optional)'),
          ),
          const SizedBox(height: 16),
          const Text('Select Tags:'),
          Wrap(
            children: widget.tags.map((tag) => FilterChip(
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
            )).toList(),
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
            final userId = Supabase.instance.client.auth.currentUser!.id;
            final newTask = Task(
              id: '',
              title: titleController.text,
              description: descController.text.isEmpty ? null : descController.text,
              tagIds: selectedTagIds,
              createdAt: DateTime.now(),
              isCompleted: false,
              userId: userId,
            );
            widget.ref.read(taskListProvider.notifier).addTask(newTask);
            Navigator.of(context).pop();
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }
}
