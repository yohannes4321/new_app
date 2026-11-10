import 'package:church_app/app/data/models/event_model.dart';
import 'package:church_app/app/data/models/live_stream_model.dart';
import 'package:church_app/app/data/models/testimony_model.dart';
import 'package:church_app/app/data/services/events_repository.dart';
import 'package:church_app/app/data/services/testimonies_repository.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'; // NEW
import '../../../data/services/home_repository.dart';

class HomeController extends GetxController {
  final homeRepository = Get.find<HomeRepository>();
  final eventsRepository = Get.find<EventsRepository>();
  final testimoniesRepository = Get.find<TestimoniesRepository>();

  var isLoading = true.obs;
  var isLiveNow = true.obs; // App 8: Core
  var youtubeId = "".obs; // Default mock ID

  // 🔥 Using Typed Models for better UI binding
  var upcomingEvents = <EventModel>[].obs;
  var testimonies = <TestimonyModel>[].obs;

  late YoutubePlayerController ytController;
  var ytReady = false.obs;

  int _weightedTestimonySort(TestimonyModel a, TestimonyModel b) {
    final aCreated = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bCreated = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

    final byNewest = bCreated.compareTo(aCreated);
    if (byNewest != 0) return byNewest;

    final byLikes = b.likeCount.compareTo(a.likeCount);
    if (byLikes != 0) return byLikes;

    final byComments = b.commentCount.compareTo(a.commentCount);
    if (byComments != 0) return byComments;

    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }

  @override
  void onInit() {
    super.onInit();
    initYoutube(); // Initialize with default or empty
    loadDashboard();
  }

  void initYoutube() {
    if (youtubeId.value.isEmpty) {
      ytReady.value = false;
      return;
    }
    _createYoutubeController(videoId: youtubeId.value, isLive: isLiveNow.value);
  }

  void _createYoutubeController({
    required String videoId,
    required bool isLive,
  }) {
    if (videoId.isEmpty) {
      return;
    }
    if (ytReady.value) {
      ytController.dispose();
    }
    ytController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(autoPlay: false, isLive: isLive),
    );
    ytReady.value = true;
  }

  void loadDashboard() async {
    isLoading(true);
    try {
      // 1. Core Logic (App 8) - from model
      final LiveStreamModel liveStream = await homeRepository.getLiveStream();
      isLiveNow.value = liveStream.isLiveNow;
      String newId = liveStream.youtubeVideoId;
      youtubeId.value = newId;
      _createYoutubeController(videoId: newId, isLive: isLiveNow.value);

      // 2. Events Mapping (App 4) - Shared repository source
      final events = await eventsRepository.getEvents();
      upcomingEvents.assignAll(events);

      // 3. Testimonies (App 5)
      final homeTestimonies = await testimoniesRepository.getTestimonies();
      homeTestimonies.sort(_weightedTestimonySort);
      testimonies.assignAll(homeTestimonies);
    } catch (e) {
      print("HomeController Error: $e");
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    if (ytReady.value) {
      ytController.dispose();
    }
    super.onClose();
  }
}
