import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../models/tag_model.dart';
import '../repositories/tag_repository.dart';

// Repository provider
final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepository();
});

// State notifier untuk tags
class TagNotifier extends StateNotifier<List<TagModel>> {
  final TagRepository _repository;

  TagNotifier(this._repository) : super([]) {
    loadTags();
  }

  Future<void> loadTags() async {
    final tags = await _repository.getAllTags();
    state = tags;
  }

  Future<void> addTag({required String name, required Color color}) async {
    final tag = TagModel.create(name: name, color: color);

    await _repository.addTag(tag);
    state = [...state, tag];
  }

  Future<void> updateTag(TagModel tag) async {
    await _repository.updateTag(tag);

    final index = state.indexWhere((t) => t.id == tag.id);
    if (index != -1) {
      final newState = [...state];
      newState[index] = tag;
      state = newState;
    }
  }

  // Method hapus tag (sudah ada)
  Future<void> deleteTag(String tagId) async {
    await _repository.deleteTag(tagId);
    state = state.where((t) => t.id != tagId).toList();
  }

  TagModel? getTagById(String id) {
    try {
      return state.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }
}

// Provider untuk tags
final tagsProvider = StateNotifierProvider<TagNotifier, List<TagModel>>((ref) {
  final repository = ref.watch(tagRepositoryProvider);
  return TagNotifier(repository);
});
