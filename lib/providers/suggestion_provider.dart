import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/suggestion.dart';
import 'common_providers.dart';

final suggestionListProvider = StateNotifierProvider<SuggestionNotifier, AsyncValue<List<Suggestion>>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SuggestionNotifier(client);
});

class SuggestionNotifier extends StateNotifier<AsyncValue<List<Suggestion>>> {
  final SupabaseClient client;

  SuggestionNotifier(this.client) : super(const AsyncValue.loading()) {
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    try {
      final userId = client.auth.currentUser!.id;
      final response = await client.from('suggestions').select().eq('user_id', userId);
      final suggestions = response.map((json) => Suggestion.fromJson(json)).toList();
      state = AsyncValue.data(suggestions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addSuggestion(Suggestion suggestion) async {
    try {
      await client.from('suggestions').insert(suggestion.toJson());
      _loadSuggestions();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateSuggestion(Suggestion updatedSuggestion) async {
    try {
      await client.from('suggestions').update(updatedSuggestion.toJson()).eq('id', updatedSuggestion.id);
      _loadSuggestions();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteSuggestion(String suggestionId) async {
    try {
      await client.from('suggestions').delete().eq('id', suggestionId);
      _loadSuggestions();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> acceptSuggestion(String suggestionId, bool accepted) async {
    try {
      await client.from('suggestions').update({'accepted': accepted}).eq('id', suggestionId);
      _loadSuggestions();
    } catch (e) {
      // Handle error
    }
  }
}
