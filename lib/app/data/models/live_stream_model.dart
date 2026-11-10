class LiveStreamModel {
  final bool isLiveNow;
  final String youtubeVideoId;

  const LiveStreamModel({
    required this.isLiveNow,
    required this.youtubeVideoId,
  });

  factory LiveStreamModel.fromJson(Map<String, dynamic> json) {
    final rawVideoValue =
        (json['youtubeVideoId'] ??
                json['youtube_video_id'] ??
                json['videoId'] ??
                json['video_id'] ??
                json['youtubeUrl'] ??
                json['youtube_url'] ??
                '')
            .toString()
            .trim();

    return LiveStreamModel(
      isLiveNow: json['isLiveNow'] == true || json['is_live_now'] == true,
      youtubeVideoId: _extractYoutubeVideoId(rawVideoValue),
    );
  }

  static String _extractYoutubeVideoId(String rawValue) {
    if (rawValue.isEmpty) {
      return '';
    }

    final uri = Uri.tryParse(rawValue);
    if (uri == null ||
        (!rawValue.contains('http') && !rawValue.contains('/'))) {
      return rawValue;
    }

    final videoFromQuery = uri.queryParameters['v'];
    if (videoFromQuery != null && videoFromQuery.isNotEmpty) {
      return videoFromQuery;
    }

    if (uri.host.contains('youtu.be') && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first;
    }

    final pathSegments = uri.pathSegments;
    for (var index = 0; index < pathSegments.length - 1; index++) {
      final segment = pathSegments[index];
      if (segment == 'embed' || segment == 'live' || segment == 'shorts') {
        return pathSegments[index + 1];
      }
    }

    return rawValue;
  }
}
