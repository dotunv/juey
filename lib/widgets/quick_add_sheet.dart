import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';
import '../providers/tag_provider.dart';
import '../providers/task_provider.dart';
import '../app/theme/color_schemes.dart';

class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({super.key});

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final Set<String> _selectedTagIds = {};
  bool _loading = false;

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final task = Task(
        id: '',
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        tagIds: _selectedTagIds.toList(),
        createdAt: DateTime.now(),
        isCompleted: false,
        userId: userId,
      );
      await ref.read(taskListProvider.notifier).addTask(task);
      HapticFeedback.lightImpact();
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(tagListProvider);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          top: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.surfaceDark2, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 8),
                Text('Quick add', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(hintText: 'Task title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Description (optional)'),
            ),
            const SizedBox(height: 12),
            tagsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
              data: (tags) => tags.isEmpty
                  ? const SizedBox.shrink()
                  : Wrap(
                      spacing: 8,
                      runSpacing: -6,
                      children: tags.take(8).map((tag) {
                        final selected = _selectedTagIds.contains(tag.id);
                        return FilterChip(
                          label: Text(tag.name),
                          selected: selected,
                          onSelected: (v) {
                            setState(() {
                              if (v) {
                                _selectedTagIds.add(tag.id);
                              } else {
                                _selectedTagIds.remove(tag.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Add task'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }
}
