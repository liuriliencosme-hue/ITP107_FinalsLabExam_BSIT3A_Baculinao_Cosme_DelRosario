import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants.dart';
import '../models/favorite_post.dart';
import '../utils/formatting.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/edit_note_dialog.dart';
import '../widgets/section_header.dart';
import '../widgets/state_message.dart';

/// Route '/favorites': reads, updates, and deletes posts saved in Hive.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  /// Update: writes the edited note back to the box under the same key.
  Future<void> _editNote(BuildContext context, Box box, FavoritePost favorite) async {
    final newNote = await showDialog<String>(
      context: context,
      builder: (_) => EditNoteDialog(
        postTitle: capitalizeFirst(favorite.title),
        initialNote: favorite.note,
      ),
    );
    if (newNote == null || newNote == favorite.note) return;

    await box.put(favorite.id, favorite.copyWith(note: newNote).toMap());
    if (!context.mounted) return;
    showAppSnackBar(context, newNote.isEmpty ? 'Note removed.' : 'Note saved.');
  }

  /// Delete: removes the post from the box, with an Undo that puts it back.
  Future<void> _deleteFavorite(BuildContext context, Box box, FavoritePost favorite) async {
    await box.delete(favorite.id);
    if (!context.mounted) return;
    showAppSnackBar(
      context,
      'Removed from favorites.',
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () => box.put(favorite.id, favorite.toMap()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Favorites'),
      ),
      // Read: rebuilds whenever the box changes, so the list is always current.
      body: ValueListenableBuilder(
        valueListenable: Hive.box(favoritesBoxName).listenable(),
        builder: (context, box, _) {
          final favorites = box.values
              .map((value) => FavoritePost.fromMap(value as Map))
              .toList()
            ..sort((a, b) => b.savedAt.compareTo(a.savedAt));

          if (favorites.isEmpty) {
            return StateMessage(
              icon: Icons.favorite_border,
              title: 'No favorites yet',
              message: 'Open any post and tap "Save to Favorites". '
                  'Saved posts stay here even after you close the app.',
              actionLabel: 'Browse posts',
              onAction: () => Navigator.pop(context),
            );
          }

          return ListView.builder(
            padding: readablePadding(context, bottom: 32),
            itemCount: favorites.length + 1,
            itemBuilder: (_, index) {
              if (index == 0) {
                final count = favorites.length;
                return SectionHeader(
                  title: 'Saved posts',
                  subtitle: '$count saved ${count == 1 ? 'post' : 'posts'} · Swipe left to remove.',
                );
              }
              final favorite = favorites[index - 1];
              return _FavoriteCard(
                favorite: favorite,
                onOpen: () => Navigator.pushNamed(
                  context,
                  AppRoutes.details,
                  arguments: favorite.toArguments(),
                ),
                onEditNote: () => _editNote(context, box, favorite),
                onDelete: () => _deleteFavorite(context, box, favorite),
              );
            },
          );
        },
      ),
    );
  }
}

/// A saved post with its note, edit-note button, and delete button.
/// Swiping it to the left also deletes it.
class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.favorite,
    required this.onOpen,
    required this.onEditNote,
    required this.onDelete,
  });

  final FavoritePost favorite;
  final VoidCallback onOpen;
  final VoidCallback onEditNote;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasNote = favorite.note.isNotEmpty;

    return Dismissible(
      key: ValueKey(favorite.id),
      direction: DismissDirection.endToStart,
      // Delete first so the list rebuilds without this card before the swipe finishes.
      confirmDismiss: (_) async {
        await onDelete();
        return true;
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: colors.onError),
            const SizedBox(width: 8),
            Text('Remove', style: textTheme.labelLarge?.copyWith(color: colors.onError)),
          ],
        ),
      ),
      child: Card(
        child: InkWell(
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          capitalizeFirst(favorite.title),
                          style: textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.favorite, size: 20, color: colors.tertiary),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    capitalizeFirst(singleLine(favorite.body)),
                    style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasNote) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _NoteBox(note: favorite.note),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Saved ${formatShortDate(favorite.savedAt)}',
                        style: textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onEditNote,
                      icon: Icon(hasNote ? Icons.edit_note : Icons.note_add_outlined, size: 20),
                      label: Text(hasNote ? 'Edit note' : 'Add note'),
                    ),
                    IconButton(
                      tooltip: 'Remove from favorites',
                      color: colors.error,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The user's personal note, shown on a soft accent background.
class _NoteBox extends StatelessWidget {
  const _NoteBox({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.sticky_note_2_outlined, size: 18, color: colors.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onTertiaryContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
