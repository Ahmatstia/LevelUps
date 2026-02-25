import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note_model.dart';
import '../repositories/note_repository.dart';

// Repository provider
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository();
});

// State notifier untuk notes
class NoteNotifier extends StateNotifier<List<NoteModel>> {
  final NoteRepository _repository;

  NoteNotifier(this._repository) : super([]) {
    loadNotes();
  }

  // Load notes dari Hive
  Future<void> loadNotes() async {
    final notes = await _repository.getAllNotes();
    state = notes;
  }

  // Tambah note
  Future<void> addNote({required String title, required String content}) async {
    final note = NoteModel.create(title: title, content: content);

    await _repository.addNote(note);
    state = [note, ...state]; // Tambah di awal
  }

  // Update note
  Future<void> updateNote(NoteModel updatedNote) async {
    final noteIndex = state.indexWhere((n) => n.id == updatedNote.id);
    if (noteIndex == -1) return;

    await _repository.updateNote(updatedNote);

    final newState = [...state];
    newState[noteIndex] = updatedNote;
    state = newState;
  }

  // Hapus note
  Future<void> deleteNote(String noteId) async {
    await _repository.deleteNote(noteId);
    state = state.where((note) => note.id != noteId).toList();
  }

  // Dapatkan note by id
  NoteModel? getNoteById(String id) {
    try {
      return state.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }
}

// Provider untuk notes
final notesProvider = StateNotifierProvider<NoteNotifier, List<NoteModel>>((
  ref,
) {
  final repository = ref.watch(noteRepositoryProvider);
  return NoteNotifier(repository);
});
