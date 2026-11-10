class HomeResponse {
  final LiveConfig liveConfig;
  final List<EventModel> upcomingEvents;
  final SermonModel latestSermon;
  final List<TestimonyModel> latestTestimonies;

  HomeResponse({
    required this.liveConfig,
    required this.upcomingEvents,
    required this.latestSermon,
    required this.latestTestimonies,
  });

  // This factory will handle the JSON coming from your Django Backend
  factory HomeResponse.fromJson(Map<String, dynamic> json) => HomeResponse(
    liveConfig: LiveConfig.fromJson(json['live_config']),
    upcomingEvents: (json['events'] as List).map((e) => EventModel.fromJson(e)).toList(),
    latestSermon: SermonModel.fromJson(json['latest_sermon']),
    latestTestimonies: (json['testimonies'] as List).map((t) => TestimonyModel.fromJson(t)).toList(),
  );
}

class LiveConfig {
  final bool isLive;
  final String? videoId;
  LiveConfig({required this.isLive, this.videoId});
  factory LiveConfig.fromJson(Map<String, dynamic> json) => LiveConfig(isLive: json['is_live_now'], videoId: json['youtube_video_id']);
}

class EventModel {
  final String day, month, title, time;
  EventModel({required this.day, required this.month, required this.title, required this.time});
  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(day: json['day'], month: json['month'], title: json['title'], time: json['time']);
}

class SermonModel {
  final String title, pastor, date, desc, image;
  SermonModel({required this.title, required this.pastor, required this.date, required this.desc, required this.image});
  factory SermonModel.fromJson(Map<String, dynamic> json) => SermonModel(
    title: json['title'], pastor: json['pastor_name'], date: json['date'], desc: json['description'], image: json['cover_image']
  );
}

class TestimonyModel {
  final String name, content, image;
  TestimonyModel({required this.name, required this.content, required this.image});
  factory TestimonyModel.fromJson(Map<String, dynamic> json) => TestimonyModel(name: json['user_name'], content: json['text_content'], image: json['profile_image']);
}