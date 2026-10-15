import 'package:flutter/material.dart';

/// Lets the user write or change a short personal note on a favorite post.
///
/// Returns the trimmed note (empty clears it), or null if the user cancels.
class EditNoteDialog extends StatefulWidget {
  const EditNoteDialog({super.key, required this.postTitle, this.initialNote = ''});

  final String postTitle;
  final String initialNote;

  @override
  State<EditNoteDialog> createState() => _EditNoteDialogState();
}

class _EditNoteDialogState extends State<EditNoteDialog> {
  late final TextEditingController _noteController =
      TextEditingController(text: widget.initialNote);

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() => Navigator.pop(context, _noteController.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(widget.initialNote.isEmpty ? 'Add a note' : 'Edit note'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.postTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _noteController,
              autofocus: true,
              minLines: 2,
              maxLines: 4,
              maxLength: 150,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Personal note',
                hintText: 'Why did you save this post?',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save note')),
      ],
    );
  }
}
