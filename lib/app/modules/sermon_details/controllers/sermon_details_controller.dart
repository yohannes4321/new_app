import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/sermon_model.dart';
import '../../../data/services/subscription_repository.dart';
import '../../../data/services/offline_media_service.dart';

class SermonDetailsController extends GetxController {
  late SermonModel sermon;
  final authService = Get.find<AuthService>();
  final subscriptionRepository = Get.find<SubscriptionRepository>();
  final offlineMedia = Get.find<OfflineMediaService>();

  // 🔥 Real Audio Player instance
  final AudioPlayer _audioPlayer = AudioPlayer();

  var isPlaying = false.obs;
  var currentPosition = 0.0.obs;
  var totalDuration = 0.0.obs;
  var playbackSpeed = 1.0.obs;
  var volume = 1.0.obs;
  var showVolumeControl = false.obs;
  var hasPremiumAccess = false.obs;
  var checkingPremium = false.obs;
  var isDownloading = false.obs;
  var offlinePath = RxnString();

  @override
  void onInit() {
    super.onInit();
    // Retrieve the sermon object passed via Get.toNamed arguments
    if (Get.arguments != null && Get.arguments is SermonModel) {
      sermon = Get.arguments as SermonModel;
      print("Sermon Loaded: ${sermon.title}");
      print("Audio URL: ${sermon.audioUrl}");
    } else {
      print("Error: No sermon data received in Detail Page");
      Get.back();
      return;
    }

    hasPremiumAccess.value = !sermon.isPremium;
    setupAudio();
    refreshPremiumAccess();
  }

  void setupAudio() {
    // 1. Listen to duration changes (how long the sermon is)
    _audioPlayer.onDurationChanged.listen((d) {
      totalDuration.value = d.inSeconds.toDouble();
    });

    // 2. Listen to position changes (updates the slider while playing)
    _audioPlayer.onPositionChanged.listen((p) {
      currentPosition.value = p.inSeconds.toDouble();
    });

    // 3. Listen to player state (Play/Pause/Stop)
    _audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;
      print("Player State changed: $state");
    });

    // 4. Log errors specifically for debugging
    _audioPlayer.onLog.listen((msg) => print("AudioPlayer Log: $msg"));
  }

  Future<void> refreshPremiumAccess() async {
    if (!sermon.isPremium) {
      hasPremiumAccess.value = true;
      return;
    }

    checkingPremium(true);
    try {
      final active = await subscriptionRepository.hasActiveSubscription();
      hasPremiumAccess.value = active;

      final updated = Map<String, dynamic>.from(authService.userProfile);
      updated['is_premium'] = active;
      authService.setUser(updated);
    } catch (_) {
      hasPremiumAccess.value = false;
    } finally {
      checkingPremium(false);
    }
  }

  void togglePlay() async {
    if (sermon.isPremium && !hasPremiumAccess.value) {
      await refreshPremiumAccess();
      if (!hasPremiumAccess.value) {
        _showUpgradeDialog();
        return; // 🛑 Stop playback here
      }
    }

    // Safety check for null URL
    if (sermon.audioUrl == null || sermon.audioUrl!.isEmpty) {
      print("Cannot play: Audio URL is null or empty");
      Get.snackbar("Error", "This sermon has no audio file available.");
      return;
    }

    try {
      if (isPlaying.value) {
        await _audioPlayer.pause();
        print("User paused audio");
      } else {
        print("Starting playback of: ${sermon.audioUrl}");
        // We use UrlSource because our mock data uses web links
        await _audioPlayer.play(
          offlinePath.value != null
              ? DeviceFileSource(offlinePath.value!)
              : UrlSource(sermon.audioUrl!),
        );
      }
    } catch (e) {
      print("Fatal error during togglePlay: $e");
      Get.snackbar("Playback Error", "Unable to play this sermon audio.");
    }
  }

  Future<void> downloadAudio() async {
    if (sermon.isPremium && !hasPremiumAccess.value) {
      await refreshPremiumAccess();
      if (!hasPremiumAccess.value) {
        _showUpgradeDialog();
        return;
      }
    }
    final url = sermon.audioUrl;
    if (url == null || url.isEmpty) return;

    try {
      isDownloading(true);
      offlinePath.value = await offlineMedia.download(
        url: url,
        id: 'sermon_${sermon.id}',
        extension: 'mp3',
      );
      Get.snackbar('Saved for offline use', 'This teaching is ready without internet.');
    } catch (_) {
      Get.snackbar('Download failed', 'Please try again when you have a stable connection.');
    } finally {
      isDownloading(false);
    }
  }

  void _showUpgradeDialog() {
    Get.defaultDialog(
      title: "Premium Content",
      middleText:
          "This sermon is part of our Premium archive. Subscribe to listen to full teachings.",
      textConfirm: "View Plans",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF4C734D),
      onConfirm: () {
        Get.back();
        Get.toNamed(Routes.SUBSCRIPTIONS);
      },
    );
  }

  void seek(double value) {
    _audioPlayer.seek(Duration(seconds: value.toInt()));
  }

  void changeSpeed() {
    if (playbackSpeed.value == 1.0) {
      playbackSpeed.value = 1.5;
    } else if (playbackSpeed.value == 1.5)
      playbackSpeed.value = 2.0;
    else
      playbackSpeed.value = 1.0;

    _audioPlayer.setPlaybackRate(playbackSpeed.value);
  }

  void toggleVolumeControl() {
    showVolumeControl.value = !showVolumeControl.value;
  }

  void setVolume(double value) {
    volume.value = value.clamp(0.0, 1.0);
    _audioPlayer.setVolume(volume.value);
  }

  String formatDuration(double seconds) {
    if (seconds <= 0) return "00:00";
    var d = Duration(seconds: seconds.toInt());
    String minutes = d.inMinutes.toString().padLeft(2, '0');
    String secs = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  void onClose() {
    print("SermonDetailsController closing, disposing player.");
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.onClose();
  }
}
