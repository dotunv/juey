import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tag.dart';
import 'common_providers.dart';

final tagListProvider = StateNotifierProvider<TagNotifier, AsyncValue<List<Tag>>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return TagNotifier(client);
});

class TagNotifier extends StateNotifier<AsyncValue<List<Tag>>> {
  final SupabaseClient client;

  TagNotifier(this.client) : super(const AsyncValue.loading()) {
    _loadTags();
  }

  Future<void> _loadTags() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }
      final response = await client.from('tags').select().eq('user_id', user.id);
      final tags = response.map((json) => Tag.fromJson(json)).toList();
      state = AsyncValue.data(tags);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addTag(Tag tag) async {
    try {
      await client.from('tags').insert(tag.toJson());
      _loadTags();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTag(Tag updatedTag) async {
    try {
      await client.from('tags').update(updatedTag.toJson()).eq('id', updatedTag.id);
      _loadTags();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteTag(String tagId) async {
    try {
      await client.from('tags').delete().eq('id', tagId);
      _loadTags();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
