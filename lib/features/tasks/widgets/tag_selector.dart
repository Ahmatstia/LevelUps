import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/tag_provider.dart';
import 'tag_management_screen.dart';

class TagSelector extends ConsumerStatefulWidget {
  final List<String> selectedTagIds;
  final Function(List<String>) onChanged;

  const TagSelector({
    super.key,
    required this.selectedTagIds,
    required this.onChanged,
  });

  @override
  ConsumerState<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends ConsumerState<TagSelector> {
  @override
  Widget build(BuildContext context) {
    final tags = ref.watch(tagsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tags',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _showCreateTagDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('New'),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TagManagementScreen(),
                      ),
                    ).then((_) => ref.refresh(tagsProvider));
                  },
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text('Manage'),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (tags.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No tags yet. Create one!',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map(
                  (tag) => FilterChip(
                    label: Text(tag.name),
                    selected: widget.selectedTagIds.contains(tag.id),
                    onSelected: (selected) {
                      final newSelection = List<String>.from(
                        widget.selectedTagIds,
                      );
                      if (selected) {
                        newSelection.add(tag.id);
                      } else {
                        newSelection.remove(tag.id);
                      }
                      widget.onChanged(newSelection);
                    },
                    backgroundColor: Colors.grey[900],
                    selectedColor: tag.color.withValues(alpha: 0.3),
                    checkmarkColor: tag.color,
                    labelStyle: TextStyle(
                      color: widget.selectedTagIds.contains(tag.id)
                          ? tag.color
                          : Colors.white,
                    ),
                    avatar: CircleAvatar(backgroundColor: tag.color, radius: 6),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  void _showCreateTagDialog() {
    final controller = TextEditingController();
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Create New Tag',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Tag name',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Select Color', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    [
                          Colors.red,
                          Colors.blue,
                          Colors.green,
                          Colors.orange,
                          Colors.purple,
                          Colors.pink,
                          Colors.teal,
                          Colors.amber,
                        ]
                        .map(
                          (color) => GestureDetector(
                            onTap: () => setState(() => selectedColor = color),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedColor == color
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  ref
                      .read(tagsProvider.notifier)
                      .addTag(name: controller.text, color: selectedColor);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
