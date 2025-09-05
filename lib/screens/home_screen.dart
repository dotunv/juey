import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/suggestion_provider.dart';
import '../providers/tag_provider.dart';
import '../services/pattern_detection_service.dart';
import '../services/suggestion_service.dart';
import '../services/notification_service.dart';
import '../widgets/task_card.dart';
import '../widgets/quick_add_sheet.dart';
import '../widgets/spark_badge.dart';
import '../app/theme/color_schemes.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(vsync: this, duration: const Duration(milliseconds: 160));
    _fabScale = Tween<double>(begin: 1, end: 0.9).animate(CurvedAnimation(parent: _fabController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _showEditBottomSheet(Task task) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);
    final selected = task.tagIds.toSet();

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      builder: (context) {
        return Consumer(builder: (context, ref, _) {
          final tagsAsync = ref.watch(tagListProvider);
          return SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 16 + MediaQuery.of(context).viewInsets.bottom, top: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [Text('Edit task', style: Theme.of(context).textTheme.titleLarge), const Spacer(), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop())]),
                  const SizedBox(height: 12),
                  TextField(controller: titleController, decoration: const InputDecoration(hintText: 'Title')),
                  const SizedBox(height: 8),
                  TextField(controller: descController, minLines: 1, maxLines: 3, decoration: const InputDecoration(hintText: 'Description (optional)')),
                  const SizedBox(height: 12),
                  tagsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (e, _) => const SizedBox.shrink(),
                    data: (tags) => Wrap(
                      spacing: 8,
                      runSpacing: -6,
                      children: tags.map((tag) {
                        final isSel = selected.contains(tag.id);
                        return FilterChip(
                          label: Text(tag.name),
                          selected: isSel,
                          onSelected: (v) {
                            setState(() {
                              if (v) {
                                selected.add(tag.id);
                              } else {
                                selected.remove(tag.id);
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
                      onPressed: () async {
                        final updated = task.copyWith(
                          title: titleController.text.trim(),
                          description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                          tagIds: selected.toList(),
                        );
                        await ref.read(taskListProvider.notifier).updateTask(updated);
                        HapticFeedback.lightImpact();
                        if (mounted) Navigator.of(context).pop();
                      },
                      child: const Text('Save changes'),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskListProvider);
    final suggestionsAsync = ref.watch(suggestionListProvider);
    final tagsAsync = ref.watch(tagListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('assets/icons/app_icon.svg', height: 20, width: 20, semanticsLabel: 'App spark'),
            const SizedBox(width: 8),
            const Text('Juey'),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const _GridBackground(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Today's picks", style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        suggestionsAsync.when(
                          loading: () => const SizedBox(height: 96, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                          error: (e, _) => Text('Error: $e'),
                          data: (suggestions) {
                            final tasks = tasksAsync.value ?? [];
                            final top = suggestions.where((s) => s.accepted != false).toList()..sort((a, b) => b.confidence.compareTo(a.confidence));
                            final top3 = top.take(3).toList();
                            if (top3.isEmpty) return const SizedBox.shrink();
                            return SizedBox(
                              height: 110,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, i) {
                                  final s = top3[i];
                                  Task? task;
                                  try {
                                    task = tasks.firstWhere((t) => t.id == s.taskId);
                                  } catch (_) {
                                    task = null;
                                  }
                                  final title = task?.title ?? 'Task';
                                  return Dismissible(
                                    key: Key('s_${s.id}'),
                                    direction: DismissDirection.horizontal,
                                    background: _dismissBg(Colors.orange, Icons.snooze, Alignment.centerLeft),
                                    secondaryBackground: _dismissBg(Colors.red, Icons.close, Alignment.centerRight),
                                    onDismissed: (dir) {
                                      ref.read(suggestionListProvider.notifier).acceptSuggestion(s.id, false);
                                      HapticFeedback.lightImpact();
                                    },
                                    child: SizedBox(
                                      width: 200,
                                      child: TaskCard(title: title, tagLabels: const [], completed: task?.isCompleted ?? false, recommended: true, onTap: () {
                                        ref.read(suggestionListProvider.notifier).acceptSuggestion(s.id, true);
                                        HapticFeedback.lightImpact();
                                      }),
                                    ),
                                  );
                                },
                                separatorBuilder: (_, __) => const SizedBox(width: 12),
                                itemCount: top3.length,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Tasks grid
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final maxW = constraints.crossAxisExtent;
                      final columns = math.max(2, math.min(3, (maxW / 160).floor()));
                      return tasksAsync.when(
                        loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                        error: (e, _) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
                        data: (tasks) {
                          if (tasks.isEmpty) {
                            return SliverGrid(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 1.25,
                              ),
                              delegate: SliverChildBuilderDelegate((context, i) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.surfaceDark2),
                                  ),
                                  child: const Center(child: _EmptySpark()),
                                );
                              }, childCount: columns * 2),
                            );
                          }

                          final tagMap = <String, String>{};
                          tagsAsync.value?.forEach((t) => tagMap[t.id] = t.name);

                          return SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.25,
                            ),
                            delegate: SliverChildBuilderDelegate((context, index) {
                              final task = tasks[index];
                              final labels = task.tagIds.map((id) => tagMap[id]).whereType<String>().toList();
                              return Dismissible(
                                key: Key(task.id),
                                direction: DismissDirection.endToStart,
                                background: _dismissBg(Colors.green, Icons.check, Alignment.centerRight),
                                onDismissed: (_) => ref.read(taskListProvider.notifier).toggleComplete(task),
                                child: TaskCard(
                                  title: task.title,
                                  tagLabels: labels,
                                  completed: task.isCompleted,
                                  onTap: () => _showEditBottomSheet(task),
                                  onLongPress: () => _showEditBottomSheet(task),
                                ),
                              );
                            }, childCount: tasks.length),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
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
            generateSuggestions(ref);
          } else if (index == 4) {
            NotificationService.showNotification('Juey Reminder', 'Time for your daily task!');
          } else if (index == 5) {
            Supabase.instance.client.auth.signOut();
          }
        },
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScale,
        child: FloatingActionButton(
          onPressed: () async {
            await _fabController.forward();
            await _fabController.reverse();
            if (!mounted) return;
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              builder: (_) => const QuickAddSheet(),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _EmptySpark extends StatelessWidget {
  const _EmptySpark();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SparkBadge(size: 22, pulse: true),
        const SizedBox(height: 8),
        Text('Add a task', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryDark)),
      ],
    );
  }
}

class _GridBackground extends StatelessWidget {
  const _GridBackground();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
      size: Size.infinite,
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = AppColors.backgroundDark;
    canvas.drawRect(Offset.zero & size, bg);

    final step = 20.0;
    final gridPaint = Paint()
      ..color = AppColors.surfaceDark2.withOpacity(0.22)
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget _dismissBg(Color color, IconData icon, Alignment alignment) {
  return Container(
    decoration: BoxDecoration(
      color: color.withOpacity(0.18),
      borderRadius: BorderRadius.circular(16),
    ),
    alignment: alignment,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Icon(icon, color: color),
  );
}
