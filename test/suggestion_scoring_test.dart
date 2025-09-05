import 'package:flutter_test/flutter_test.dart';
import 'package:jueymobile/utils/text_utils.dart';
import 'package:jueymobile/utils/suggestion_scoring.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tzdata.initializeTimeZones();
  final loc = tz.local;

  test('recency scaling saturates at 30 days', () {
    expect(recencyFromDays(0), 0.0);
    expect(recencyFromDays(15), closeTo(0.5, 1e-6));
    expect(recencyFromDays(30), 1.0);
    expect(recencyFromDays(45), 1.0);
  });

  test('frequency weights mapping', () {
    expect(frequencyWeight('daily'), 1.0);
    expect(frequencyWeight('weekly'), 0.8);
    expect(frequencyWeight('monthly'), 0.6);
    expect(frequencyWeight('none'), 0.3);
    expect(frequencyWeight('irregular'), 0.3);
  });

  test('time match logic bucket and weekend', () {
    final now = tz.TZDateTime(tz.local, 2025, 1, 1, 20); // evening, weekday
    final history = <DateTime>[];
    // 7 out of 10 in evening, 7 out of 10 on weekdays
    for (int i = 0; i < 7; i++) {
      history.add(DateTime(2024, 12, 1, 20)); // evening weekday
    }
    for (int i = 0; i < 3; i++) {
      history.add(DateTime(2024, 12, 1, 9)); // morning weekday
    }
    final parts = timeMatchParts(history, loc, now);
    expect(parts.$1, 1.0); // bucket match
    expect(parts.$2, 1.0); // weekday match
  });

  test('jaccard similarity for tokens and tags', () {
    final a = TextUtils.tokenize('Write a weekly report');
    final b = TextUtils.tokenize('Weekly status report');
    final tokSim = TextUtils.jaccard(a.toSet(), b.toSet());
    expect(tokSim, greaterThan(0.0));

    final tagA = {'work', 'writing'};
    final tagB = {'work', 'planning'};
    final tagSim = TextUtils.jaccard(tagA, tagB);
    expect(tagSim, closeTo(1 / 3, 1e-6));
  });

  test('similarity combines tokens and tags with max over recent', () {
    final recent = <(String, List<String>)>[
      ('Grocery shopping', ['home', 'errand']),
      ('Weekly status report', ['work', 'writing'])
    ];
    final sim = maxSimilarityToRecent(
      candidateTitle: 'Write a weekly report',
      candidateTagIds: ['work', 'report'],
      recent: recent,
    );
    expect(sim, greaterThan(0.2));
  });

  test('stable ranking by score then lastDone', () {
    final now = DateTime(2025, 1, 1);
    final items = <(double, DateTime, int)>[
      (0.7, now.subtract(const Duration(days: 1)), 0),
      (0.7, now.subtract(const Duration(days: 2)), 1),
      (0.6, now, 2),
    ];
    final order = stableRankIndices(items);
    expect(order, [0, 1, 2]);
  });
}
