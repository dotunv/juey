import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/tag_provider.dart';

class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({super.key, this.initial});

  final Task? initial;

  static Future<void> show(BuildContext context, {Task? initial}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: QuickAddSheet(initial: initial),
      ),
    );
  }

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _form = GlobalKey<FormState>();
  List<String> _selectedTagIds = [];
  bool _showDescription = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      final t = widget.initial!;
      _titleController.text = t.title;
      _descController.text = t.description ?? '';
      _selectedTagIds = [...t.tagIds];
      _showDescription = t.description?.isNotEmpty == true;
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (widget.initial == null) {
        final userId = Supabase.instance.client.auth.currentUser!.id;
        final newTask = Task(
          id: '',
          title: _titleController.text.trim(),
          description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
          tagIds: _selectedTagIds,
          createdAt: DateTime.now(),
          isCompleted: false,
          userId: userId,
        );
        await ref.read(taskListProvider.notifier).addTask(newTask);
      } else {
        final updated = widget.initial!.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
          tagIds: _selectedTagIds,
        );
        await ref.read(taskListProvider.notifier).updateTask(updated);
      }
      HapticFeedback.lightImpact();
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tagAsync = ref.watch(tagListProvider);
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(widget.initial == null ? 'Quick add' : 'Edit task', style: Theme.of(context).textTheme.headlineMedium),
                  const Spacer(),
                  IconButton(
                    tooltip: _showDescription ? 'Hide description' : 'Add description',
                    onPressed: () => setState(() => _showDescription = !_showDescription),
                    icon: Icon(_showDescription ? Icons.subject : Icons.notes, color: cs.onSurface.withOpacity(0.8)),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Task title'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
                onFieldSubmitted: (_) => _save(),
              ),
              if (_showDescription) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Optional description'),
                ),
              ],
              const SizedBox(height: 12),
              if (tagAsync.hasValue && tagAsync.value!.isNotEmpty) ...[
                Text('Tags', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final tag in tagAsync.value!)
                      FilterChip(
                        label: Text(tag.name),
                        selected: _selectedTagIds.contains(tag.id),
                        onSelected: (s) => setState(() {
                          if (s) {
                            _selectedTagIds.add(tag.id);
                          } else {
                            _selectedTagIds.remove(tag.id);
                          }
                        }),
                      )
                  ],
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: Text(widget.initial == null ? 'Save' : 'Update'),
                  onPressed: _saving ? null : _save,
                ),
              )
            ],
          ),
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
