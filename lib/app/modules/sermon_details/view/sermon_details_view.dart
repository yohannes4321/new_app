import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../controllers/sermon_details_controller.dart';

class SermonDetailsView extends GetView<SermonDetailsController> {
  const SermonDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final sermon = controller.sermon;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Now Playing",
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        centerTitle: true,
      ),
      // 🔥 Wrapped in SingleChildScrollView to fix the 3.7px overflow
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            30,
            20,
            30,
            40,
          ), // Adjusted padding
          child: Column(
            children: [
              _buildSermonImage(sermon),
              const SizedBox(height: 30),

              Text(
                sermon.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                sermon.pastorName,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // THE GATE
              Obx(() {
                if (controller.checkingPremium.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(color: Color(0xFF4C734D)),
                  );
                }

                if (sermon.isPremium && !controller.hasPremiumAccess.value) {
                  return _buildPaywallUI(); // From your current code
                }
                return _buildPlayerControls(context); // From your current code
              }),

              const SizedBox(height: 40),
              Obx(() => OutlinedButton.icon(
                onPressed: controller.isDownloading.value ? null : controller.downloadAudio,
                icon: const Icon(Icons.download_outlined),
                label: Text(controller.isDownloading.value ? 'Saving…' : 'Save for offline'),
              )),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => GestureDetector(
                        onTap: () => controller.changeSpeed(),
                        child: _playerBottomTab(
                          Icons.timer_outlined,
                          "Speed ${controller.playbackSpeed.value}x",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSermonImage(sermon) {
    return Hero(
      tag: 'sermon_img_${sermon.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.network(
            sermon.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF4C734D),
              child: const Icon(
                Icons.music_note,
                size: 100,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaywallUI() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4C734D).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_outline, size: 40, color: Color(0xFF4C734D)),
          const SizedBox(height: 12),
          const Text(
            "Premium Teaching",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            "Subscribe to unlock our full archive of audio teachings.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Get.toNamed(Routes.SUBSCRIPTIONS),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C734D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Unlock Now",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerControls(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => Slider(
            value: controller.currentPosition.value,
            max: controller.totalDuration.value,
            onChanged: (v) => controller.seek(v),
            activeColor: const Color(0xFF4C734D),
            inactiveColor: Colors.grey.shade200,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.formatDuration(controller.currentPosition.value),
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  controller.formatDuration(controller.totalDuration.value),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Obx(
              () => SizedBox(
                width: 56,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      bottom: controller.showVolumeControl.value ? 44 : 18,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: controller.showVolumeControl.value ? 1 : 0,
                        child: IgnorePointer(
                          ignoring: !controller.showVolumeControl.value,
                          child: Container(
                            width: 54,
                            height: 150,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 7,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 14,
                                  ),
                                ),
                                child: Slider(
                                  value: controller.volume.value,
                                  onChanged: controller.setVolume,
                                  activeColor: const Color(0xFF4C734D),
                                  inactiveColor: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        controller.volume.value == 0
                            ? Icons.volume_off_outlined
                            : Icons.volume_up_outlined,
                      ),
                      onPressed: controller.toggleVolumeControl,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous, size: 40),
              onPressed: () {},
            ),
            Obx(
              () => GestureDetector(
                onTap: () => controller.togglePlay(),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: const Color(0xFF4C734D),
                  child: Icon(
                    controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, size: 40),
              onPressed: () {},
            ),
            const SizedBox(width: 56),
          ],
        ),
      ],
    );
  }

  Widget _playerBottomTab(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
