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
import '../services/notification_service.dart';
import '../widgets/task_card.dart';
import '../widgets/quick_add_sheet.dart';
import '../widgets/spark_badge.dart';

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
    _fabController = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    _fabScale = Tween<double>(begin: 1.0, end: 0.88).animate(CurvedAnimation(parent: _fabController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  int _gridColumns(double width) {
    final c = (width / 160).floor();
    return c.clamp(2, 3);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tasksAsync = ref.watch(taskListProvider);
    final suggestionsAsync = ref.watch(suggestionListProvider);
    final reasons = ref.watch(suggestionReasonsProvider);
    final tagsAsync = ref.watch(tagListProvider);

    final Set<String> recommendedTaskIds = {
      if (suggestionsAsync.hasValue)
        ...suggestionsAsync.value!.map((s) => s.taskId),
    };

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('assets/icons/app_icon.svg', width: 20, height: 20, semanticsLabel: 'Spark'),
            const SizedBox(width: 8),
            const Text('Juey'),
          ],
        ),
      ),
      body: Container(
        decoration: const _GridBackground(),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Text("Today's picks", style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            suggestionsAsync.when(
              loading: () => const SliverToBoxAdapter(child: SizedBox(height: 68)),
              error: (e, _) => SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('Error loading picks: $e'))),
              data: (sugs) {
                final picks = sugs.take(3).toList();
                if (picks.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 120,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: picks.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final s = picks[i];
                        final task = tasksAsync.value?.firstWhere((t) => t.id == s.taskId, orElse: () => Task(
                              id: '',
                              title: 'Task',
                              description: null,
                              tagIds: const [],
                              createdAt: DateTime.now(),
                              isCompleted: false,
                              userId: '',
                            ));
                        return Dismissible(
                          key: Key('pick_${s.id}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.only(right: 16),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
                            child: const Icon(Icons.close, color: Colors.white),
                          ),
                          onDismissed: (_) async {
                            await ref.read(suggestionListProvider.notifier).rejectSuggestion(s.id);
                            HapticFeedback.lightImpact();
                            await ref.read(suggestionListProvider.notifier).refreshTopSuggestions();
                          },
                          child: SizedBox(
                            width: 240,
                            child: Card(
                              child: InkWell(
                                onTap: () async {
                                  await ref.read(suggestionListProvider.notifier).acceptSuggestion(s.id);
                                  HapticFeedback.lightImpact();
                                  await ref.read(suggestionListProvider.notifier).refreshTopSuggestions();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const SparkBadge(size: 18, shimmer: true),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              task?.title ?? 'Task',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context).textTheme.titleLarge,
                                            ),
                                          ),
                                          const Icon(Icons.chevron_right),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(
                                        reasons[s.id] ?? 'Recommended for now',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.7)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final columns = _gridColumns(constraints.crossAxisExtent);
                  return tasksAsync.when(
                    loading: () => const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))),
                    error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
                    data: (tasks) {
                      if (tasks.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 32),
                                const SparkBadge(size: 48, shimmer: true),
                                const SizedBox(height: 12),
                                Text('No tasks yet', style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 8),
                                Text('Tap + to quickly add your first task', style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        );
                      }

                      // Resolve tag names
                      final tagMap = {for (final t in (tagsAsync.value ?? [])) t.id: t.name};

                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.1,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final task = tasks[index];
                            final tagLabels = [for (final id in task.tagIds) if (tagMap[id] != null) tagMap[id]!];
                            final isRecommended = recommendedTaskIds.contains(task.id);

                            final card = TaskCard(
                              task: task,
                              tagLabels: tagLabels,
                              recommended: isRecommended,
                              onTap: () async {
                                await ref.read(taskListProvider.notifier).toggleComplete(task);
                                HapticFeedback.lightImpact();
                              },
                              onLongPress: () => QuickAddSheet.show(context, initial: task),
                              onToggleComplete: () async {
                                await ref.read(taskListProvider.notifier).toggleComplete(task);
                                HapticFeedback.lightImpact();
                              },
                            );

                            return Dismissible(
                              key: Key('task_${task.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(16)),
                                child: const Icon(Icons.check, color: Colors.white),
                              ),
                              onDismissed: (_) async {
                                await ref.read(taskListProvider.notifier).toggleComplete(task);
                                HapticFeedback.lightImpact();
                              },
                              child: card,
                            );
                          },
                          childCount: tasks.length,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
            ref.read(suggestionListProvider.notifier).refreshTopSuggestions();
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
            await QuickAddSheet.show(context);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _GridBackground extends Decoration {
  const _GridBackground();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _GridPainter();
}

class _GridPainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final rect = offset & configuration.size!;
    final paint1 = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 1;
    final paint2 = Paint()
      ..color = const Color(0xFF2B2B2B)
      ..strokeWidth = 1;

    const gap = 24.0;
    for (double x = rect.left; x < rect.right; x += gap) {
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), x % (gap * 2) == 0 ? paint1 : paint2);
    }
    for (double y = rect.top; y < rect.bottom; y += gap) {
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), y % (gap * 2) == 0 ? paint1 : paint2);
    }
  }
}
