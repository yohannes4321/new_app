import 'package:church_app/app/routes/app_routes.dart';
import 'package:church_app/app/widgets/main_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/events_controller.dart';
import '../../../data/models/event_model.dart';

class EventsView extends GetView<EventsController> {
  const EventsView({super.key});
  static const String _eventPlaceholder = 'assets/images/event_placeholder.png';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        MainBottomNav.backOrHome();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: const MainBottomNav(activeRoute: Routes.EVENTS),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: MainBottomNav.backOrHome,
          ),
          title: const Text(
            "Events",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            // Dynamic Search Bar
            Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFF4F4F4,
                ), // Greyish background matching Sermons
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: controller.searchController,
                onChanged: (val) => controller.searchEvents(val),
                decoration: InputDecoration(
                  hintText: "Search events...",
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Reactive Grid
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredEvents.isEmpty) {
                  return const Center(child: Text("No events found."));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75, // Matching Sermons layout
                  ),
                  itemCount: controller.filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = controller.filteredEvents[index];
                    return _buildEventGridItem(event);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventGridItem(EventModel event) {
    return GestureDetector(
      // FIXED: Match the route exactly
      onTap: () => Get.toNamed(Routes.EVENT_DETAILS, arguments: event),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE HANDLING
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: event.imageUrl.isEmpty
                    ? Image.asset(
                        _eventPlaceholder,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        event.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                              _eventPlaceholder,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                      ),
              ),
            ),
            // CONTENT SECTION
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      "${event.day} ${event.month}",
                      style: const TextStyle(
                        color: Color(0xFF4C734D),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
