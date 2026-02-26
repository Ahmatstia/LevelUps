import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/note_provider.dart';
import '../../core/models/note_model.dart';
import '../../core/theme/game_theme.dart';
import 'widgets/add_note_bottom_sheet.dart';
import 'widgets/note_detail_screen.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    final filteredNotes = _filterNotes(notes);

    return Scaffold(
      backgroundColor: GameTheme.background,
      appBar: AppBar(
        backgroundColor: GameTheme.background,
        elevation: 0,
        title: Text(
          'NOTES',
          style: GameTheme.neonTextStyle(GameTheme.neonCyan, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Container(
              decoration: BoxDecoration(
                color: GameTheme.surface,
                border: Border.all(
                  color: GameTheme.neonCyan.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'SEARCH LOGS...',
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.grey[700],
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: GameTheme.neonCyan.withValues(alpha: 0.5),
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey[600],
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),

          // Notes Grid/List
          Expanded(
            child: filteredNotes.isEmpty
                ? _buildEmptyState()
                : _buildNotesGrid(filteredNotes),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: GameTheme.goldYellow.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAddNoteSheet,
          backgroundColor: GameTheme.goldYellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.black87, width: 2),
          ),
          child: const Icon(Icons.add, color: Colors.black, size: 24),
        ),
      ),
    );
  }

  List<NoteModel> _filterNotes(List<NoteModel> notes) {
    if (_searchQuery.isEmpty) return notes;

    return notes.where((note) {
      return note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 56,
            color: GameTheme.neonCyan.withValues(alpha: 0.3),
            shadows: [
              Shadow(
                color: GameTheme.neonCyan.withValues(alpha: 0.2),
                blurRadius: 12,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'NO LOGS YET',
            style: GameTheme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'TAP + TO CREATE YOUR FIRST LOG',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: Colors.grey[700],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesGrid(List<NoteModel> notes) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildNoteCard(note, index);
      },
    );
  }

  Widget _buildNoteCard(NoteModel note, int index) {
    final date =
        '${note.updatedAt.day}/${note.updatedAt.month}/${note.updatedAt.year}';

    return GestureDetector(
      onTap: () => _openNoteDetail(note),
      child:
          Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: GameTheme.surface,
                  border: Border.all(
                    color: GameTheme.neonCyan.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: GameTheme.neonCyan.withValues(alpha: 0.06),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      note.title.toUpperCase(),
                      style: GameTheme.textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        letterSpacing: 0.5,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: GameTheme.neonCyan.withValues(alpha: 0.08),
                        border: Border.all(
                          color: GameTheme.neonCyan.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        date,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 8,
                          color: GameTheme.neonCyan.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Preview content
                    Text(
                      note.content,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    // Delete button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => _deleteNote(note.id),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: GameTheme.hpRed.withValues(alpha: 0.1),
                              border: Border.all(
                                color: GameTheme.hpRed.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              color: GameTheme.hpRed.withValues(alpha: 0.7),
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .animate(delay: (index * 60).ms)
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.95, 0.95)),
    );
  }

  void _showAddNoteSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddNoteBottomSheet(),
    );
  }

  void _openNoteDetail(NoteModel note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteDetailScreen(note: note)),
    );
  }

  Future<void> _deleteNote(String noteId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameTheme.surface,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: GameTheme.hpRed, width: 1.5),
        ),
        title: Text(
          'DELETE LOG',
          style: GameTheme.textTheme.bodySmall?.copyWith(
            color: GameTheme.hpRed,
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this log?',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'CANCEL',
              style: GameTheme.textTheme.bodySmall?.copyWith(
                fontSize: 8,
                color: Colors.grey[500],
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: GameTheme.hpRed),
            child: Text(
              'DELETE',
              style: GameTheme.textTheme.bodySmall?.copyWith(
                fontSize: 8,
                color: GameTheme.hpRed,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(notesProvider.notifier).deleteNote(noteId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: GameTheme.surface,
              content: Text(
                'LOG DELETED',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: GameTheme.goldYellow,
                  fontSize: 12,
                ),
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: GameTheme.hpRed,
            ),
          );
        }
      }
    }
  }
}
