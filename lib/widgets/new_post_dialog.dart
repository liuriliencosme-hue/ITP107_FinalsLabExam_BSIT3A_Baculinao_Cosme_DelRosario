import 'package:flutter/material.dart';

/// Asks for a title and body for a new post. Neither field may be empty.
///
/// Returns the entered values, or null if the user cancels.
class NewPostDialog extends StatefulWidget {
  const NewPostDialog({super.key});

  @override
  State<NewPostDialog> createState() => _NewPostDialogState();
}

class _NewPostDialogState extends State<NewPostDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  String? _requireText(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, (
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('New post'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your post is sent to DummyJSON with an HTTP POST request.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Give your post a title',
                ),
                validator: (value) => _requireText(value, 'Title'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  hintText: 'What would you like to say?',
                  alignLabelWithHint: true,
                ),
                validator: (value) => _requireText(value, 'Body'),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.send_outlined, size: 18),
          label: const Text('Send post'),
        ),
      ],
    );
  }
}
