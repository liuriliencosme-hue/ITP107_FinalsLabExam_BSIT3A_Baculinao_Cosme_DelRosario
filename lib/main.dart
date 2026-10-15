import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'constants.dart';
import 'screens/details_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/posts_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Hive needs the Flutter engine ready before it can locate app storage.
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(favoritesBoxName);

  runApp(const PostReaderApp());
}

class PostReaderApp extends StatelessWidget {
  const PostReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Post Reader & Favorites',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.posts,
      routes: {
        AppRoutes.posts: (context) => const PostsScreen(),
        AppRoutes.details: (context) => const DetailsScreen(),
        AppRoutes.favorites: (context) => const FavoritesScreen(),
      },
    );
  }
}

  