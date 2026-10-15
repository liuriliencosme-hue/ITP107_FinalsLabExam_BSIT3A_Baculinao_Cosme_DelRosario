/// Named routes registered in [MaterialApp.routes].
class AppRoutes {
  static const String posts = '/';
  static const String details = '/details';
  static const String favorites = '/favorites';
}

/// DummyJSON endpoint for reading (GET) all posts. `limit=0` returns every post.
const String postsApiUrl = 'https://dummyjson.com/posts?limit=0';

/// DummyJSON endpoint for creating (POST) a new post.
const String createPostApiUrl = 'https://dummyjson.com/posts/add';

/// Name of the Hive box that stores favorite posts on the device.
const String favoritesBoxName = 'favoritePostsBox';
