/// A post returned by the DummyJSON API.
class Post {
  const Post({required this.id, required this.title, required this.body});

  final int id;
  final String title;
  final String body;

  /// Builds a post from one item of the decoded JSON list.
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  /// The arguments sent to the details screen through [Navigator.pushNamed].
  Map<String, dynamic> toArguments() => {'id': id, 'title': title, 'body': body};
}
