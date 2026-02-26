import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/note_provider.dart';
import '../../../core/theme/game_theme.dart';

class AddNoteBottomSheet extends ConsumerStatefulWidget {
  const AddNoteBottomSheet({super.key});

  @override
  ConsumerState<AddNoteBottomSheet> createState() => _AddNoteBottomSheetState();
}

class _AddNoteBottomSheetState extends ConsumerState<AddNoteBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: GameTheme.surface,
        border: const Border(
          top: BorderSide(color: GameTheme.neonCyan, width: 2),
          left: BorderSide(color: GameTheme.neonCyan, width: 1),
          right: BorderSide(color: GameTheme.neonCyan, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: GameTheme.neonCyan.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'NEW LOG ENTRY',
              style: GameTheme.neonTextStyle(GameTheme.neonCyan, fontSize: 12),
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Field
                    Text(
                      'TITLE',
                      style: GameTheme.textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        color: GameTheme.neonCyan,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter log title ...',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: GameTheme.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            color: GameTheme.neonCyan.withValues(alpha: 0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            color: GameTheme.neonCyan.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color: GameTheme.neonCyan,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Content Field
                    Text(
                      'CONTENT',
                      style: GameTheme.textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        color: GameTheme.neonCyan,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _contentController,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      maxLines: 10,
                      decoration: InputDecoration(
                        hintText: 'Write your log here...',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: GameTheme.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            color: GameTheme.neonCyan.withValues(alpha: 0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            color: GameTheme.neonCyan.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color: GameTheme.neonCyan,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter content';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: Colors.grey[700]!,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'CANCEL',
                          style: GameTheme.textTheme.bodySmall?.copyWith(
                            fontSize: 9,
                            color: Colors.grey[500],
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _addNote,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: GameTheme.neonCyan.withValues(alpha: 0.15),
                        border: Border.all(
                          color: GameTheme.neonCyan,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: GameTheme.neonCyan.withValues(alpha: 0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'SAVE LOG',
                          style: GameTheme.textTheme.bodySmall?.copyWith(
                            fontSize: 9,
                            color: GameTheme.neonCyan,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addNote() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref
            .read(notesProvider.notifier)
            .addNote(
              title: _titleController.text,
              content: _contentController.text,
            );

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: GameTheme.surface,
              content: Text(
                'LOG SAVED',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: GameTheme.staminaGreen,
                  fontSize: 12,
                ),
              ),
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
