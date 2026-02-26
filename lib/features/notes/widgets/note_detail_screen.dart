import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/note_model.dart';
import '../../../core/providers/note_provider.dart';
import '../../../core/theme/game_theme.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  final NoteModel note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date =
        '${widget.note.updatedAt.day}/${widget.note.updatedAt.month}/${widget.note.updatedAt.year} ${widget.note.updatedAt.hour}:${widget.note.updatedAt.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: GameTheme.background,
      appBar: AppBar(
        backgroundColor: GameTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: GameTheme.neonCyan.withValues(alpha: 0.7),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(
                Icons.edit,
                color: GameTheme.manaBlue,
                shadows: [Shadow(color: GameTheme.manaBlue, blurRadius: 8)],
              ),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing) ...[
            IconButton(
              icon: Icon(
                Icons.close,
                color: GameTheme.hpRed,
                shadows: [Shadow(color: GameTheme.hpRed, blurRadius: 8)],
              ),
              onPressed: () {
                setState(() => _isEditing = false);
                _titleController.text = widget.note.title;
                _contentController.text = widget.note.content;
              },
            ),
            IconButton(
              icon: Icon(
                Icons.check,
                color: GameTheme.staminaGreen,
                shadows: [Shadow(color: GameTheme.staminaGreen, blurRadius: 8)],
              ),
              onPressed: _updateNote,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  fontSize: 10,
                  color: GameTheme.neonCyan.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            _isEditing
                ? TextFormField(
                    controller: _titleController,
                    style: GameTheme.neonTextStyle(
                      GameTheme.neonCyan,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.grey[700],
                      ),
                      border: InputBorder.none,
                    ),
                  )
                : Text(
                    widget.note.title.toUpperCase(),
                    style: GameTheme.neonTextStyle(
                      GameTheme.neonCyan,
                      fontSize: 14,
                    ),
                  ),
            const SizedBox(height: 8),
            Container(
              height: 1,
              color: GameTheme.neonCyan.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 20),

            // Content
            _isEditing
                ? TextFormField(
                    controller: _contentController,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.6,
                    ),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Write your log...',
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.grey[700],
                      ),
                      border: InputBorder.none,
                    ),
                  )
                : Text(
                    widget.note.content,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.grey[300],
                      height: 1.6,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateNote() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: GameTheme.surface,
          content: Text(
            'TITLE AND CONTENT CANNOT BE EMPTY',
            style: TextStyle(
              fontFamily: 'Inter',
              color: GameTheme.hpRed,
              fontSize: 11,
            ),
          ),
        ),
      );
      return;
    }

    try {
      final updatedNote = widget.note.copyWith(
        title: _titleController.text,
        content: _contentController.text,
      );

      await ref.read(notesProvider.notifier).updateNote(updatedNote);

      setState(() => _isEditing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: GameTheme.surface,
            content: Text(
              'LOG UPDATED',
              style: TextStyle(
                fontFamily: 'Inter',
                color: GameTheme.staminaGreen,
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
