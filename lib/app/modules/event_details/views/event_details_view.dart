import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/event_details_controller.dart';

class EventDetailsView extends GetView<EventDetailsController> {
  const EventDetailsView({super.key});
  static const String _eventPlaceholder = 'assets/images/event_placeholder.png';

  @override
  Widget build(BuildContext context) {
    final event = controller.event;

    if (event == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            "Event Details",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: const Center(child: Text("Event not found.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 22,
          ),
          onPressed: () => Get.back(),
        ),
      ),

      body: Column(
        children: [
          // --- SMART IMAGE LOADER ---
          event.imageUrl.isEmpty
              ? Image.asset(
                  _eventPlaceholder,
                  height: 450,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Image.network(
                  event.imageUrl,
                  height: 450,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // If the URL exists but the link is broken, show your local image
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      _eventPlaceholder,
                      height: 450,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                  // While loading the network image, show a shimmer or local image
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 450,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),

          Expanded(
            child: Container(
              transform: Matrix4.translationValues(0, -60, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              padding: const EdgeInsets.fromLTRB(
                24,
                36,
                24,
                0,
              ), // 🔥 remove bottom padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.formattedFullDate.toUpperCase(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "Mission For Nation",
                    style: TextStyle(
                      color: Colors.deepOrangeAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    event.description,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.justify, //  makes both sides straight
                    style: TextStyle(
                      color: Colors.grey[700],
                      height: 1.6,
                      fontSize: 15,
                    ),
                  ),

                  // pushes button fully down
                  const Spacer(),

                  Obx(() {
                    if (!event.allowsRegistration) {
                      return const Center(
                        child: Text(
                          "Informational Event Only",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.toggleRegistration(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.isRegistered.value
                              ? Colors.grey[200]
                              : const Color(0xFF333333),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                controller.isRegistered.value
                                    ? "Cancel Registration"
                                    : "Join event",
                                style: TextStyle(
                                  color: controller.isRegistered.value
                                      ? Colors.black87
                                      : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
