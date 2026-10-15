import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/post.dart';
import '../utils/formatting.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/new_post_dialog.dart';
import '../widgets/section_header.dart';
import '../widgets/state_message.dart';

/// Route '/': lists posts from DummyJSON and lets the user create one.
class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<Post> _posts = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  /// GET the first 30 posts. Shows them on status 200, otherwise shows an error message.
  Future<void> _fetchPosts() async {
    try {
      final response = await http
          .get(Uri.parse(postsApiUrl))
          .timeout(const Duration(seconds: 15));
      if (!mounted) return;

      if (response.statusCode == 200) {
        // DummyJSON wraps the list: {"posts": [...], "total": ..., ...}
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> postsJson = data['posts'];
        setState(() {
          _posts = postsJson
              .map((json) => Post.fromJson(json as Map<String, dynamic>))
              .toList();
          _errorMessage = null;
          _isLoading = false;
        });
      } else {
        _showLoadError(
          'The server responded with status code ${response.statusCode}. Please try again.',
        );
      }
    } catch (error) {
      if (!mounted) return;
      _showLoadError(
        'Could not connect to the server. Check your internet connection and try again.',
      );
    }
  }

  void _showLoadError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _fetchPosts();
  }

  Future<void> _openNewPostDialog() async {
    final draft = await showDialog<({String title, String body})>(
      context: context,
      builder: (context) => const NewPostDialog(),
    );
    if (draft != null) await _createPost(draft.title, draft.body);
  }

  /// POST a new post. DummyJSON answers 201 (Created) but does not keep it.
  Future<void> _createPost(String title, String body) async {
    setState(() => _isSending = true);
    try {
      final response = await http
          .post(
            Uri.parse(createPostApiUrl),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'title': title, 'body': body, 'userId': 1}),
          )
          .timeout(const Duration(seconds: 15));
      if (!mounted) return;

      if (response.statusCode == 201) {
        final created = jsonDecode(response.body) as Map<String, dynamic>;
        showAppSnackBar(
          context,
          'Post created successfully! Server returned id ${created['id']} (status 201).',
        );
      } else {
        showAppSnackBar(
          context,
          'Failed to create post. The server responded with status ${response.statusCode}.',
          isError: true,
        );
      }
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Failed to create post. Check your internet connection and try again.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _openDetails(Post post) {
    Navigator.pushNamed(context, AppRoutes.details, arguments: post.toArguments());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Reader'),
        actions: [
          IconButton(
            tooltip: 'Favorites',
            icon: const Icon(Icons.favorite_border),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.favorites),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSending ? null : _openNewPostDialog,
        tooltip: 'Create a new post',
        icon: _isSending
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.edit_outlined),
        label: Text(_isSending ? 'Sending...' : 'New post'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingView(message: 'Loading posts...');
    }

    if (_errorMessage != null) {
      return StateMessage(
        icon: Icons.cloud_off_outlined,
        title: "Couldn't load posts",
        message: _errorMessage!,
        actionLabel: 'Try again',
        onAction: _retry,
        isError: true,
      );
    }

    // Rebuilds the list when favorites change so saved posts show a heart.
    return ValueListenableBuilder(
      valueListenable: Hive.box(favoritesBoxName).listenable(),
      builder: (context, favoritesBox, _) {
        return RefreshIndicator(
          onRefresh: _fetchPosts,
          child: ListView.builder(
            padding: readablePadding(context, bottom: 96),
            itemCount: _posts.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return SectionHeader(
                  title: 'Latest posts',
                  subtitle: '${_posts.length} posts · Tap one to read it, pull down to refresh.',
                );
              }
              final post = _posts[index - 1];
              return _PostTile(
                post: post,
                isFavorite: favoritesBox.containsKey(post.id),
                onTap: () => _openDetails(post),
              );
            },
          ),
        );
      },
    );
  }
}

/// One post in the list: number badge, title, and a short body preview.
class _PostTile extends StatelessWidget {
  const _PostTile({required this.post, required this.isFavorite, required this.onTap});

  final Post post;
  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${post.id}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
        title: Text(
          capitalizeFirst(post.title),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            capitalizeFirst(singleLine(post.body)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: isFavorite
            ? Icon(Icons.favorite, color: colors.tertiary, semanticLabel: 'In favorites')
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}
