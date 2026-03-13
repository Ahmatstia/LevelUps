import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/note_model.dart';
import '../../../core/providers/note_provider.dart';
import '../../../core/theme/app_theme.dart';

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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(
                Icons.edit,
                color: AppTheme.manaBlue,
              ),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing) ...[
            IconButton(
              icon: Icon(
                Icons.close,
                color: AppTheme.hpRed,
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
                color: AppTheme.staminaGreen,
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
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                date,
                style: AppTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            _isEditing
                ? TextFormField(
                    controller: _titleController,
                    style: AppTheme.textTheme.titleLarge?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: AppTheme.textTheme.titleLarge?.copyWith(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.bold,
                      ),
                      border: InputBorder.none,
                    ),
                  )
                : Text(
                    widget.note.title.toUpperCase(),
                    style: AppTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            const SizedBox(height: 8),
            Container(
              height: 1,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),

            // Content
            _isEditing
                ? TextFormField(
                    controller: _contentController,
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                      height: 1.6,
                    ),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Write your log...',
                      hintStyle: AppTheme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                      border: InputBorder.none,
                    ),
                  )
                : Text(
                    widget.note.content,
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[800],
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
          backgroundColor: AppTheme.surface,
          content: Text(
            'TITLE AND CONTENT CANNOT BE EMPTY',
            style: AppTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.hpRed,
              fontWeight: FontWeight.bold,
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
            backgroundColor: AppTheme.surface,
            content: Text(
              'LOG UPDATED',
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
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
            backgroundColor: AppTheme.hpRed,
          ),
        );
      }
    }
  }
}
