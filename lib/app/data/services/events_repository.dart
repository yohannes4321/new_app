import 'package:get/get.dart';
import '../models/event_model.dart';
import 'auth_service.dart';

class EventsRepository extends GetConnect {
  final _auth = Get.find<AuthService>();

  @override
  void onInit() {
    httpClient.baseUrl = "https://church-backend-s1rb.onrender.com/api";
    httpClient.timeout = const Duration(seconds: 30);
    super.onInit();
  }

  // GET /api/events
  Future<List<EventModel>> getEvents() async {
    // 1. Fetch public list
    final res = await get(
      "/events",
      headers: {'Authorization': 'Bearer ${_auth.authToken}'},
    );

    // 2. Fetch YOUR private registration list
    final myEventsRes = await get(
      "/events/my-events",
      headers: {'Authorization': 'Bearer ${_auth.authToken}'},
    );

    if (res.isOk) {
      final List eventsData = res.body['data'] ?? [];
      final List<EventModel> events = eventsData
          .map((e) => EventModel.fromJson(e))
          .toList();

      // 3. MERGE LOGIC: Force the status from private my-events list
      if (myEventsRes.isOk && myEventsRes.body['data'] != null) {
        final List myEvents = myEventsRes.body['data'];
        // Extract the event IDs that you actually joined
        final Set<String> joinedIds = myEvents
            .map((e) => e['event_id'].toString())
            .toSet();

        for (final event in events) {
          // Force the flag based on the private list
          event.isUserRegistered = joinedIds.contains(event.id);
        }
      }

      // Keep newest/recent events first for UI consistency.
      events.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      return events;
    } else {
      print("❌ Failed to fetch events: ${res.body}");
      return [];
    }
  }

  // POST /api/events/:id/register
  Future<bool> register(String eventId) async {
    final res = await post(
      "/events/$eventId/register",
      {},
      headers: {'Authorization': 'Bearer ${_auth.authToken}'},
    );
    return res.status.isOk;
  }

  // DELETE /api/events/:id/unregister
  Future<bool> unregister(String eventId) async {
    final res = await delete(
      "/events/$eventId/unregister",
      headers: {'Authorization': 'Bearer ${_auth.authToken}'},
    );
    return res.status.isOk;
  }

  // GET /api/events/my-events -> Set of joined event IDs
  Future<Set<String>> getMyJoinedEventIds() async {
    final res = await get(
      "/events/my-events",
      headers: {'Authorization': 'Bearer ${_auth.authToken}'},
    );

    if (res.isOk && res.body['data'] != null) {
      final List myEventsData = res.body['data'];
      // Extract event_ids and put them into a Set (very fast to check)
      return myEventsData.map((e) => e['event_id'].toString()).toSet();
    }
    return {};
  }
}
