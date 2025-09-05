import 'dart:math';
import 'package:timezone/timezone.dart' as tz;
import 'time_context.dart';
import 'text_utils.dart';

double recencyFromDays(int days, {int dMax = 30}) {
  if (days <= 0) return 0.0;
  return min(days / dMax, 1.0);
}

double frequencyWeight(String? freq) {
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

(double, double) timeMatchParts(List<DateTime> times, tz.Location loc, tz.TZDateTime now) {
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

double maxSimilarityToRecent({
  required String candidateTitle,
  required List<String> candidateTagIds,
  required List<(String title, List<String> tagIds)> recent,
}) {
  final ctoks = TextUtils.tokenize(candidateTitle).toSet();
  final ctags = candidateTagIds.toSet();
  double maxSim = 0.0;
  for (final r in recent) {
    final rtoks = TextUtils.tokenize(r.$1).toSet();
    final rtags = r.$2.toSet();
    final tagSim = TextUtils.jaccard(ctags, rtags);
    final tokSim = TextUtils.jaccard(ctoks, rtoks);
    final pair = 0.5 * tagSim + 0.5 * tokSim;
    if (pair > maxSim) maxSim = pair;
  }
  return maxSim;
}

List<int> stableRankIndices(List<(double score, DateTime lastDone, int idx)> items) {
  final list = List.of(items);
  list.sort((a, b) {
    final c = b.$1.compareTo(a.$1);
    if (c != 0) return c;
    final c2 = b.$2.compareTo(a.$2);
    if (c2 != 0) return c2;
    return a.$3.compareTo(b.$3);
  });
  return list.map((e) => e.$3).toList();
}
