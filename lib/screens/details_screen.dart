import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants.dart';
import '../models/favorite_post.dart';
import '../utils/formatting.dart';
import '../widgets/app_snack_bar.dart';

/// Route '/details': shows one post and saves it to favorites.
class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The post is passed in by Navigator.pushNamed(..., arguments: {...}).
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int id = args['id'];
    final String title = args['title'];
    final String body = args['body'];

    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Post Details'),
      ),
      body: SingleChildScrollView(
        padding: readablePadding(context, top: 28, bottom: 32, minSide: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'POST #$id',
                style: textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(capitalizeFirst(title), style: textTheme.headlineMedium),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            Text(capitalizeFirst(singleLine(body)), style: textTheme.bodyLarge),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: readablePadding(context, top: 8, bottom: 16),
          child: _SaveToFavoritesButton(id: id, title: title, body: body),
        ),
      ),
    );
  }
}

/// "Save to Favorites" button that turns into a saved state once the post is in Hive.
class _SaveToFavoritesButton extends StatelessWidget {
  const _SaveToFavoritesButton({required this.id, required this.title, required this.body});

  final int id;
  final String title;
  final String body;

  /// Create: stores the post as a Map, using the post id as the key so the
  /// same post can never be saved twice.
  Future<void> _saveToFavorites(BuildContext context, Box box) async {
    if (box.containsKey(id)) {
      showAppSnackBar(context, 'This post is already in your favorites.');
      return;
    }

    final favorite = FavoritePost(id: id, title: title, body: body, savedAt: DateTime.now());
    await box.put(id, favorite.toMap());
    if (!context.mounted) return;
    showAppSnackBar(context, 'Saved to favorites.');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ValueListenableBuilder(
      valueListenable: Hive.box(favoritesBoxName).listenable(keys: [id]),
      builder: (context, box, _) {
        final isSaved = box.containsKey(id);

        return SizedBox(
          width: double.infinity,
          height: 52,
          child: isSaved
              ? OutlinedButton.icon(
                  onPressed: () => _saveToFavorites(context, box),
                  icon: Icon(Icons.favorite, color: colors.tertiary),
                  label: const Text('Saved to Favorites'),
                )
              : FilledButton.icon(
                  onPressed: () => _saveToFavorites(context, box),
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('Save to Favorites'),
                ),
        );
      },
    );
  }
}
