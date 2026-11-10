class TestimonyComment {
  final String userId;
  final String postedBy;
  final String text;
  final DateTime? createdAt;

  TestimonyComment({
    required this.userId,
    required this.postedBy,
    required this.text,
    this.createdAt,
  });

  factory TestimonyComment.fromJson(Map<String, dynamic> json) {
    return TestimonyComment(
      userId: json['user_id']?.toString() ?? '',
      postedBy: json['posted_by']?.toString() ?? 'Anonymous',
      text: json['text']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class TestimonyModel {
  final String id;
  final String title;
  final String content;
  final String verse;
  final List<String> images;
  final String postedBy;
  final DateTime? createdAt;
  int likeCount;
  int commentCount;
  bool isLiked; // This is what we will calculate
  final String? youtubeVideoId;
  final List<TestimonyComment> comments;

  TestimonyModel({
    required this.id,
    required this.title,
    required this.content,
    required this.verse,
    required this.images,
    required this.postedBy,
    this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.youtubeVideoId,
    this.comments = const [],
  });

  // ✅ UPDATED factory to take 'currentUserId'
  factory TestimonyModel.fromJson(
    Map<String, dynamic> json,
    String? currentUserId,
  ) {
    // 1. Get the list of likes from the backend
    List likesList = json['likes'] as List? ?? [];

    final serverIsLiked = json['is_liked'];
    final bool resolvedIsLiked = serverIsLiked is bool
        ? serverIsLiked
        : (currentUserId != null && likesList.contains(currentUserId));

    final createdRaw = json['createdAt'] ?? json['created_at'];

    return TestimonyModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['text_content'] ?? '',
      verse: json['verse'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      postedBy: json['posted_by'] ?? "Mission For Nation",
      createdAt: createdRaw != null
          ? DateTime.tryParse(createdRaw.toString())
          : null,
      youtubeVideoId: json['youtube_video_id'],
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,

      // Prefer backend truth ('is_liked'); fallback to uid+likes list.
      isLiked: resolvedIsLiked,
      comments:
          (json['comments'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(TestimonyComment.fromJson)
              .toList() ??
          const [],
    );
  }
}
