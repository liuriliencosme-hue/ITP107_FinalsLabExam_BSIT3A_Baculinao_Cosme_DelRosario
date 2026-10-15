/// A post saved in the Hive favorites box, plus the user's personal note.
///
/// It is stored in Hive as a plain Map (see [toMap]), keyed by the post id.
class FavoritePost {
  const FavoritePost({
    required this.id,
    required this.title,
    required this.body,
    required this.savedAt,
    this.note = '',
  });

  final int id;
  final String title;
  final String body;
  final DateTime savedAt;
  final String note;

  /// Hive returns stored maps as `Map<dynamic, dynamic>`, so values are read by key.
  factory FavoritePost.fromMap(Map<dynamic, dynamic> map) {
    return FavoritePost(
      id: map['id'] as int,
      title: map['title'] as String,
      body: map['body'] as String,
      savedAt: DateTime.parse(map['savedAt'] as String),
      note: (map['note'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'savedAt': savedAt.toIso8601String(),
        'note': note,
      };

  FavoritePost copyWith({String? note}) {
    return FavoritePost(
      id: id,
      title: title,
      body: body,
      savedAt: savedAt,
      note: note ?? this.note,
    );
  }

  /// Arguments for opening this post on the details screen.
  Map<String, dynamic> toArguments() => {'id': id, 'title': title, 'body': body};
}
