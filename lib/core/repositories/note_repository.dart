import 'package:hive/hive.dart';
import '../models/note_model.dart';

class NoteRepository {
  static const String _boxName = 'notes';

  // Mendapatkan box
  Future<Box<NoteModel>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<NoteModel>(_boxName);
    }
    return await Hive.openBox<NoteModel>(_boxName);
  }

  // Tambah note
  Future<void> addNote(NoteModel note) async {
    final box = await _getBox();
    await box.put(note.id, note);
  }

  // Ambil semua notes
  Future<List<NoteModel>> getAllNotes() async {
    final box = await _getBox();
    final notes = box.values.toList();
    // Sort by updatedAt descending (terbaru di atas)
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  // Ambil note by id
  Future<NoteModel?> getNote(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  // Update note
  Future<void> updateNote(NoteModel note) async {
    final box = await _getBox();
    await box.put(note.id, note);
  }

  // Hapus note
  Future<void> deleteNote(String noteId) async {
    final box = await _getBox();
    await box.delete(noteId);
  }

  // Hapus semua notes
  Future<void> deleteAllNotes() async {
    final box = await _getBox();
    await box.clear();
  }
}
