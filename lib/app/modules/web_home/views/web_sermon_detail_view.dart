import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../sermon_details/controllers/sermon_details_controller.dart';

class WebSermonDetailView extends GetView<SermonDetailsController> {
  const WebSermonDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final sermon = controller.sermon; // Data from the 'Brain'

    return Scaffold(
      backgroundColor: const Color(0xFF18181C), // Matching your dark UI
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: context.height - MediaQuery.of(context).padding.top - kToolbarHeight),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // --- 1. CENTERED IMAGE ---
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    sermon.imageUrl,
                    height: 400,
                    width: 400,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
    
              // --- 2. TITLE AND PASTOR ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 48), // Balancing for the vertical dots
                  Column(
                    children: [
                      Text(
                        sermon.title,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sermon.pastorName,
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
    
              const SizedBox(height: 40),
    
              // --- 3. PLAYER CONTROLS (From your image) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(icon: const Icon(Icons.shuffle, color: Colors.grey, size: 20), onPressed: () {}),
                          const SizedBox(width: 20),
                          IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white, size: 30), onPressed: () {}),
                          const SizedBox(width: 20),
                          
                          // Reactive Play/Pause
                          Obx(() => IconButton(
                            icon: Icon(
                              controller.isPlaying.value ? Icons.pause_circle_filled : Icons.play_circle_filled,
                              color: Colors.white, size: 60,
                            ),
                            onPressed: () => controller.togglePlay(),
                          )),
                          
                          const SizedBox(width: 20),
                          IconButton(icon: const Icon(Icons.skip_next, color: Colors.white, size: 30), onPressed: () {}),
                          const SizedBox(width: 20),
                          IconButton(icon: const Icon(Icons.repeat, color: Colors.grey, size: 20), onPressed: () {}),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
    
                      // --- 4. PROGRESS BAR ---
                      Row(
                        children: [
                          Obx(() => Text(
                            controller.formatDuration(controller.currentPosition.value),
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          )),
                          Expanded(
                            child: Obx(() => Slider(
                              value: controller.currentPosition.value,
                              max: controller.totalDuration.value,
                              activeColor: Colors.grey.shade700,
                              inactiveColor: Colors.grey.shade900,
                              onChanged: (v) => controller.seek(v),
                            )),
                          ),
                          Obx(() => Text(
                            controller.formatDuration(controller.totalDuration.value),
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}