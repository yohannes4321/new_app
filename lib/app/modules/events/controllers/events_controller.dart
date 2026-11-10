import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/event_model.dart';
import '../../../data/services/events_repository.dart';

class EventsController extends GetxController {
  final eventsRepository = Get.find<EventsRepository>();

  var isLoading = true.obs;
  var eventsList = <EventModel>[].obs;
  var filteredEvents = <EventModel>[].obs;

  // 🔥 ADD THIS: The missing controller for the search bar
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  // 🔥 THE FIX: This runs every single time the user navigates to the Events tab
  @override
  void onReady() {
    super.onReady();
    fetchEvents();
  }

  @override
  void onClose() {
    // Always dispose controllers to save memory
    searchController.dispose();
    super.onClose();
  }

  void fetchEvents() async {
    // If we already have data, don't show the big center spinner to keep it smooth
    if (eventsList.isEmpty) isLoading(true);

    try {
      final events = await eventsRepository.getEvents();

      // 🔥 THE SYNC: Tell the controller to update the UI instantly
      eventsList.assignAll(events);
      filteredEvents.assignAll(events);

      // Re-apply any active search filters
      if (searchController.text.isNotEmpty) {
        searchEvents(searchController.text);
      }
    } catch (e) {
      print("Error fetching events: $e");
    } finally {
      isLoading(false);
    }
  }

  // 🔥 ADD THIS: The logic to filter events based on user input
  void searchEvents(String query) {
    if (query.isEmpty) {
      filteredEvents.assignAll(eventsList);
    } else {
      filteredEvents.assignAll(
        eventsList
            .where(
              (e) =>
                  e.title.toLowerCase().contains(query.toLowerCase()) ||
                  e.location.toLowerCase().contains(query.toLowerCase()),
            )
            .toList(),
      );
    }
  }
}
