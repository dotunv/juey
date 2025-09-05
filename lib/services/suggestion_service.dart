import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/suggestion.dart';
import '../models/task.dart';
import '../models/pattern.dart';
import '../providers/suggestion_provider.dart';
import '../providers/pattern_provider.dart';
import '../providers/task_provider.dart';
import '../utils/text_utils.dart';
import '../utils/time_context.dart';
import '../utils/feedback_prefs.dart';

Future<void> generateSuggestions(WidgetRef ref) async {
  await generateSuggestionsV1(ref);
}

class _Candidate {
  final String normalizedTitle;
  final Task task; // representative most recent instance
  final DateTime lastDone;
  final Pattern? pattern;
  final List<Task> history;

  _Candidate({
    required this.normalizedTitle,
    required this.task,
    required this.lastDone,
    required this.pattern,
    required this.history,
  });
}

class _ScoredCandidate {
  final _Candidate cand;
  final double recencyBoost;
  final double frequencyBoost;
  final double timeMatch;
  final double similarity;
  final double feedbackBoost;
  final double score;
  final String reason;

  _ScoredCandidate({
    required this.cand,
    required this.recencyBoost,
    required this.frequencyBoost,
    required this.timeMatch,
    required this.similarity,
    required this.feedbackBoost,
    required this.score,
    required this.reason,
  });
}

double _recencyFromDays(int days, {int dMax = 30}) {
  if (days <= 0) return 0.0;
  return min(days / dMax, 1.0);
}

double _frequencyWeight(String? freq) {
  switch ((freq ?? 'none').toLowerCase()) {
    case 'daily':
      return 1.0;
    case 'weekly':
      return 0.8;
    case 'monthly':
      return 0.6;
    case 'none':
    case 'irregular':
    default:
      return 0.3;
  }
}

(double, double) _timeMatchParts(List<DateTime> times, tz.Location loc, tz.TZDateTime now) {
  if (times.isEmpty) return (0.5, 0.5);
  final buckets = <DayBucket, int>{};
  int weekendCount = 0;
  for (final t in times) {
    final z = TimeContext.toTz(t, loc);
    final b = TimeContext.hourBucket(z);
    buckets[b] = (buckets[b] ?? 0) + 1;
    if (TimeContext.isWeekend(z)) weekendCount++;
  }
  final total = times.length;
  final nowBucket = TimeContext.hourBucket(now);
  final bucketShare = (buckets[nowBucket] ?? 0) / total;
  final isNowWeekend = TimeContext.isWeekend(now);
  final weekendShare = (isNowWeekend ? weekendCount : (total - weekendCount)) / total;
  final bucketScore = bucketShare > 0.6 ? 1.0 : 0.0;
  final weekScore = weekendShare > 0.6 ? 1.0 : 0.0;
  return (bucketScore, weekScore);
}

String _bucketLabel(DayBucket b) {
  switch (b) {
    case DayBucket.morning:
      return 'morning';
    case DayBucket.midday:
      return 'midday';
    case DayBucket.afternoon:
      return 'afternoon';
    case DayBucket.evening:
      return 'evening';
    case DayBucket.night:
      return 'night';
  }
}

String _buildReason({
  required double recency,
  required double freq,
  required double time,
  required double sim,
  required double feedback,
  required tz.TZDateTime now,
  required List<DateTime> times,
  required tz.Location loc,
  required String? freqLabel,
}) {
  final weights = {
    'recency': 0.35 * recency,
    'frequency': 0.25 * freq,
    'time': 0.20 * time,
    'similarity': 0.15 * sim,
    'feedback': 0.05 * feedback,
  };
  final sorted = weights.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  String phrase(String key) {
    switch (key) {
      case 'recency':
        return "It’s been a while since last time";
      case 'frequency':
        final label = (freqLabel ?? '').isEmpty ? 'your routine' : 'your ${freqLabel!.toLowerCase()} routine';
        return 'Part of $label';
      case 'time':
        final (bucketScore, weekScore) = _timeMatchParts(times, loc, now);
        String p1 = '';
        if (bucketScore == 1.0) {
          p1 = 'You usually do this in the ${_bucketLabel(TimeContext.hourBucket(now))}';
        }
        String p2 = '';
        if (weekScore == 1.0) {
          p2 = TimeContext.isWeekend(now) ? 'on weekends' : 'on weekdays';
        }
        return [p1, p2].where((e) => e.isNotEmpty).join(' ');
      case 'similarity':
        return 'Similar to your recent activity';
      case 'feedback':
        return 'You’ve accepted this before';
      default:
        return '';
    }
  }

  final top2 = sorted.take(2).map((e) => phrase(e.key)).where((s) => s.isNotEmpty).toList();
  return top2.join(' • ');
}

Future<List<Suggestion>> generateSuggestionsV1(WidgetRef ref, {int limit = 8}) async {
  final client = Supabase.instance.client;
  final userId = client.auth.currentUser!.id;
  final loc = tz.local;
  final now = tz.TZDateTime.now(loc);

  // Fetch minimal task data
  final taskRows = await client
      .from('tasks')
      .select('id,title,tag_ids,created_at,completed_at,is_completed,user_id')
      .eq('user_id', userId);
  final tasks = (taskRows as List).map((j) => Task.fromJson(j)).toList();

  // Fetch patterns
  List<Pattern> patterns = ref.read(patternListProvider).value ?? [];
  if (patterns.isEmpty) {
    final patternRows = await client.from('patterns').select().eq('user_id', userId);
    patterns = (patternRows as List).map((j) => Pattern.fromJson(j)).toList();
  }

  // Build history by normalized title
  final grouped = <String, List<Task>>{};
  for (final t in tasks) {
    final key = TextUtils.normalizeTitle(t.title);
    grouped.putIfAbsent(key, () => []).add(t);
  }

  // Helper: last done per title
  final lastDoneByTitle = <String, DateTime>{};
  for (final entry in grouped.entries) {
    DateTime? last;
    for (final t in entry.value) {
      final dt = t.completedAt ?? t.createdAt;
      if (last == null || dt.isAfter(last)) last = dt;
    }
    if (last != null) lastDoneByTitle[entry.key] = last!;
  }

  bool isToday(DateTime dt) {
    final z = TimeContext.toTz(dt, loc);
    return z.year == now.year && z.month == now.month && z.day == now.day;
  }

  // Candidates from patterns first
  final candidates = <String, _Candidate>{};
  final patternByTaskId = {for (final p in patterns) p.taskId: p};
  for (final p in patterns) {
    // find the task instance for this pattern's title (by its taskId, then dedupe by title)
    final task = tasks.firstWhere((t) => t.id == p.taskId, orElse: () => tasks.firstWhere((t) => TextUtils.normalizeTitle(t.title) == TextUtils.normalizeTitle(tasks.firstWhere((tt) => tt.id == p.taskId).title), orElse: () => tasks.first));
    final key = TextUtils.normalizeTitle(task.title);
    final hist = grouped[key] ?? [];
    final last = lastDoneByTitle[key] ?? (task.completedAt ?? task.createdAt);
    if (isToday(last)) continue; // exclude tasks completed today
    candidates[key] = _Candidate(
      normalizedTitle: key,
      task: hist.isNotEmpty
          ? hist.reduce((a, b) => ((a.completedAt ?? a.createdAt).isAfter(b.completedAt ?? b.createdAt)) ? a : b)
          : task,
      lastDone: last,
      pattern: p,
      history: hist,
    );
  }

  // Then recently completed tasks in past 60 days
  final cutoff = now.subtract(const Duration(days: 60)).toUtc();
  for (final entry in grouped.entries) {
    final key = entry.key;
    if (candidates.containsKey(key)) continue;
    final hist = entry.value;
    if (hist.isEmpty) continue;
    // find most recent instance
    hist.sort((a, b) => (b.completedAt ?? b.createdAt).compareTo(a.completedAt ?? a.createdAt));
    final mostRecent = hist.first;
    final last = mostRecent.completedAt ?? mostRecent.createdAt;
    if (last.isBefore(cutoff)) continue;
    if (isToday(last)) continue;
    candidates[key] = _Candidate(
      normalizedTitle: key,
      task: mostRecent,
      lastDone: last,
      pattern: patternByTaskId[mostRecent.id],
      history: hist,
    );
  }

  // Compute scores
  final scored = <_ScoredCandidate>[];
  // recent tasks set for similarity (last 7 days)
  final recentCut = now.subtract(const Duration(days: 7));
  final recentTasks = tasks.where((t) {
    final dt = t.completedAt ?? t.createdAt;
    final z = TimeContext.toTz(dt, loc);
    return z.isAfter(recentCut);
  }).toList();

  for (final cand in candidates.values) {
    final last = TimeContext.toTz(cand.lastDone, loc);
    final daysSince = now.difference(last).inDays;
    final rec = _recencyFromDays(daysSince);
    final freq = _frequencyWeight(cand.pattern?.frequency);

    // time match
    final times = cand.history.map((t) => t.completedAt ?? t.createdAt).toList();
    final (bucketScore, weekScore) = _timeMatchParts(times, loc, now);
    final timeMatch = (bucketScore + weekScore) / 2.0;

    // similarity
    final candTokens = TextUtils.tokenize(cand.task.title).toSet();
    final candTags = cand.task.tagIds.toSet();
    double maxSim = 0.0;
    for (final rt in recentTasks) {
      final tTokens = TextUtils.tokenize(rt.title).toSet();
      final tTags = rt.tagIds.toSet();
      final tagSim = TextUtils.jaccard(candTags, tTags);
      final tokenSim = TextUtils.jaccard(candTokens, tTokens);
      final pair = 0.5 * tagSim + 0.5 * tokenSim;
      if (pair > maxSim) maxSim = pair;
    }

    // feedback
    final avg = await FeedbackPrefs.getAvg(cand.normalizedTitle);
    final nudge = await FeedbackPrefs.getNudge(cand.normalizedTitle);
    final global = await FeedbackPrefs.getGlobalMultiplier();
    final fb = (FeedbackPrefs.mapAvgToBoost(avg) * nudge * global).clamp(0.3, 1.0);

    final score = (0.35 * rec) + (0.25 * freq) + (0.20 * timeMatch) + (0.15 * maxSim) + (0.05 * fb);

    final reason = _buildReason(
      recency: rec,
      freq: freq,
      time: timeMatch,
      sim: maxSim,
      feedback: fb,
      now: now,
      times: times,
      loc: loc,
      freqLabel: cand.pattern?.frequency,
    );

    scored.add(_ScoredCandidate(
      cand: cand,
      recencyBoost: rec,
      frequencyBoost: freq,
      timeMatch: timeMatch,
      similarity: maxSim,
      feedbackBoost: fb,
      score: score,
      reason: reason,
    ));
  }

  // Rank: stable by score desc then lastDone desc
  for (int i = 0; i < scored.length; i++) {
    // attach index for stability
  }
  scored.sort((a, b) {
    final c = b.score.compareTo(a.score);
    if (c != 0) return c;
    final c2 = b.cand.lastDone.compareTo(a.cand.lastDone);
    if (c2 != 0) return c2;
    // stable fallback by title
    return a.cand.normalizedTitle.compareTo(b.cand.normalizedTitle);
  });

  final top = scored.take(limit).toList();

  // Insert into Supabase and capture IDs
  final rowsToInsert = top
      .map((s) => {
            'task_id': s.cand.task.id,
            'confidence': double.parse(s.score.toStringAsFixed(4)),
            'suggested_at': DateTime.now().toIso8601String(),
            'user_id': userId,
          })
      .toList();

  final inserted = await client.from('suggestions').insert(rowsToInsert).select();
  final suggestions = (inserted as List).map((j) => Suggestion.fromJson(j)).toList();

  // Push reasons map into provider state for UI
  final reasonsMap = <String, String>{};
  for (int i = 0; i < suggestions.length; i++) {
    reasonsMap[suggestions[i].id] = top[i].reason;
  }
  ref.read(suggestionReasonsProvider.notifier).state = reasonsMap;

  // Update list provider state
  ref.read(suggestionListProvider.notifier).setSuggestions(suggestions);

  return suggestions;
}
