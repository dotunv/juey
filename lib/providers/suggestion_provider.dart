import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/suggestion.dart';
import '../models/task.dart';
import 'common_providers.dart';
import '../utils/feedback_prefs.dart';
import '../utils/text_utils.dart';
import '../services/suggestion_service.dart' as svc;
import 'task_provider.dart';

final suggestionReasonsProvider = StateProvider<Map<String, String>>((ref) => {});

final suggestionListProvider = StateNotifierProvider<SuggestionNotifier, AsyncValue<List<Suggestion>>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SuggestionNotifier(ref, client);
});

class SuggestionNotifier extends StateNotifier<AsyncValue<List<Suggestion>>> {
  final SupabaseClient client;
  final Ref ref;

  SuggestionNotifier(this.ref, this.client) : super(const AsyncValue.loading()) {
    refreshTopSuggestions();
  }

  void setSuggestions(List<Suggestion> suggestions) {
    state = AsyncValue.data(suggestions);
  }

  Future<void> refreshTopSuggestions({int limit = 8}) async {
    try {
      state = const AsyncValue.loading();
      final suggestions = await svc.generateSuggestionsV1(ref, limit: limit);
      state = AsyncValue.data(suggestions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> acceptSuggestion(String suggestionId) async {
    try {
      await client.from('suggestions').update({'accepted': true}).eq('id', suggestionId);
      await _updateFeedbackForSuggestion(suggestionId, true);
    } catch (e) {
      // ignore
    }
  }

  Future<void> rejectSuggestion(String suggestionId) async {
    try {
      await client.from('suggestions').update({'accepted': false}).eq('id', suggestionId);
      await _updateFeedbackForSuggestion(suggestionId, false);
    } catch (e) {
      // ignore
    }
  }

  Future<void> _updateFeedbackForSuggestion(String suggestionId, bool accepted) async {
    final current = state.value ?? [];
    Suggestion? s;
    for (final x in current) {
      if (x.id == suggestionId) {
        s = x;
        break;
      }
    }
    if (s == null) return;
    List<Task> tasks = ref.read(taskListProvider).value ?? [];
    Task? t;
    for (final tt in tasks) {
      if (tt.id == s.taskId) {
        t = tt;
        break;
      }
    }
    if (t == null) {
      final row = await client.from('tasks').select('id,title,user_id').eq('id', s.taskId).maybeSingle();
      if (row != null) {
        t = Task.fromJson({
          'id': row['id'],
          'title': row['title'],
          'description': null,
          'tag_ids': <String>[],
          'created_at': DateTime.now().toIso8601String(),
          'completed_at': null,
          'is_completed': false,
          'user_id': row['user_id'] ?? client.auth.currentUser!.id,
        });
      }
    }
    if (t == null) return;
    final key = TextUtils.normalizeTitle(t.title);
    await FeedbackPrefs.updateAvg(key, accepted);
    await FeedbackPrefs.adjustNudge(key, accepted);
  }
}
