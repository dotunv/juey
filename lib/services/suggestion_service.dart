import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/suggestion.dart';
import '../providers/suggestion_provider.dart';
import '../providers/pattern_provider.dart';

Future<void> generateSuggestions(WidgetRef ref) async {
  final patterns = ref.read(patternListProvider).value ?? [];
  if (patterns.isEmpty) return;

  final userId = Supabase.instance.client.auth.currentUser!.id;

  for (var pattern in patterns) {
    bool shouldSuggest = false;
    double confidence = 0.5;

    if (pattern.frequency == 'daily' && pattern.lastDone.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      shouldSuggest = true;
      confidence = 0.8;
    } else if (pattern.frequency == 'weekly' && pattern.lastDone.isBefore(DateTime.now().subtract(const Duration(days: 7)))) {
      shouldSuggest = true;
      confidence = 0.7;
    } else if (pattern.frequency == 'monthly' && pattern.lastDone.isBefore(DateTime.now().subtract(const Duration(days: 30)))) {
      shouldSuggest = true;
      confidence = 0.6;
    }

    if (shouldSuggest) {
      final suggestion = Suggestion(
        id: '',
        taskId: pattern.taskId,
        confidence: confidence,
        suggestedAt: DateTime.now(),
        userId: userId,
      );
      ref.read(suggestionListProvider.notifier).addSuggestion(suggestion);
    }
  }
}
