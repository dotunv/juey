import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pattern.dart';
import 'common_providers.dart';

final patternListProvider = StateNotifierProvider<PatternNotifier, AsyncValue<List<Pattern>>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return PatternNotifier(client);
});

class PatternNotifier extends StateNotifier<AsyncValue<List<Pattern>>> {
  final SupabaseClient client;

  PatternNotifier(this.client) : super(const AsyncValue.loading()) {
    _loadPatterns();
  }

  Future<void> _loadPatterns() async {
    try {
      final userId = client.auth.currentUser!.id;
      final response = await client.from('patterns').select().eq('user_id', userId);
      final patterns = response.map((json) => Pattern.fromJson(json)).toList();
      state = AsyncValue.data(patterns);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addPattern(Pattern pattern) async {
    try {
      await client.from('patterns').insert(pattern.toJson());
      _loadPatterns();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updatePattern(Pattern updatedPattern) async {
    try {
      await client.from('patterns').update(updatedPattern.toJson()).eq('id', updatedPattern.id);
      _loadPatterns();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deletePattern(String patternId) async {
    try {
      await client.from('patterns').delete().eq('id', patternId);
      _loadPatterns();
    } catch (e) {
      // Handle error
    }
  }
}
