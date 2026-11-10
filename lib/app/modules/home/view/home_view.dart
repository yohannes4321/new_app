import 'package:church_app/app/routes/app_routes.dart';
import 'package:church_app/app/data/services/auth_service.dart';
import 'package:church_app/app/data/services/notification_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';
import 'package:church_app/app/widgets/main_bottom_nav.dart';
import '../controllers/home_controller.dart';
import '../../../data/models/event_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const String _eventPlaceholder = 'assets/images/event_placeholder.png';
  final HomeController controller = Get.find<HomeController>();
  final AuthService authService = Get.find<AuthService>();
  final NotificationService notificationService =
      Get.find<NotificationService>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLandscape =
          MediaQuery.of(context).orientation == Orientation.landscape;

      if (!controller.ytReady.value) {
        return WillPopScope(
          onWillPop: () async {
            SystemNavigator.pop();
            return false;
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            extendBody: true,
            appBar: isLandscape
                ? null
                : AppBar(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    leadingWidth: 92,
                    leading: _buildAppBarLogo(),
                    actions: [
                      _buildNotificationButton(),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: GestureDetector(
                          onTap: () => Get.toNamed(Routes.PROFILE),
                          child: _buildProfileAvatar(),
                        ),
                      ),
                    ],
                  ),
            body: controller.isLoading.value
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4C734D)),
                  )
                : SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildFillerBanner(),
                        ),
                        const SizedBox(height: 24),
                        _buildQuickActions(),
                        const SizedBox(height: 32),
                        _buildSectionHeader("Upcoming Events", '/events'),
                        _buildHorizontalEventSection(),
                        const SizedBox(height: 16),
                        _buildSectionHeader("Testimony", '/testimonies'),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 100, // Added padding to avoid bar overlap
                          ),
                          child: _buildTestimonySection(),
                        ),
                      ],
                    ),
                  ),
            bottomNavigationBar: const MainBottomNav(activeRoute: Routes.HOME),
          ),
        );
      }

      return YoutubePlayerBuilder(
        onEnterFullScreen: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        },
        onExitFullScreen: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        },
        player: YoutubePlayer(
          controller: controller.ytController,
          showVideoProgressIndicator: true,
        ),
        builder: (context, player) {
          return WillPopScope(
            onWillPop: () async {
              SystemNavigator.pop();
              return false;
            },
            child: Scaffold(
              backgroundColor: const Color(0xFFF9FAFB),
              extendBody: true,
              appBar: isLandscape
                  ? null
                  : AppBar(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      leadingWidth: 92,
                      leading: _buildAppBarLogo(),
                      actions: [
                        _buildNotificationButton(),
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: GestureDetector(
                            onTap: () => Get.toNamed(Routes.PROFILE),
                            child: _buildProfileAvatar(),
                          ),
                        ),
                      ],
                    ),
              body: isLandscape
                  ? Center(child: player)
                  : controller.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4C734D),
                      ),
                    )
                  : SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: controller.isLiveNow.value
                                ? _buildLiveSection(player)
                                : _buildFillerBanner(),
                          ),
                          const SizedBox(height: 24),
                          _buildQuickActions(),
                          const SizedBox(height: 32),
                          _buildSectionHeader("Upcoming Events", '/events'),
                          _buildHorizontalEventSection(),
                          const SizedBox(height: 16),
                          _buildSectionHeader("Testimony", '/testimonies'),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: 100, // Added padding to avoid bar overlap
                            ),
                            child: _buildTestimonySection(),
                          ),
                        ],
                      ),
                    ),
              bottomNavigationBar: isLandscape
                  ? null
                  : const MainBottomNav(activeRoute: Routes.HOME),
            ),
          );
        },
      );
    });
  }

  // --- CUSTOM FLOATING NAV BAR ---

  Widget _buildNotificationButton() {
    return Obx(() {
      final unread = notificationService.unreadCount.value;
      final icon = const Icon(Icons.notifications_none_outlined);

      return IconButton(
        icon: unread > 0
            ? Badge(
                smallSize: 6,
                largeSize: 14,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                label: Text(
                  unread > 99 ? '99+' : '$unread',
                  style: const TextStyle(fontSize: 9),
                ),
                child: icon,
              )
            : icon,
        onPressed: notificationService.openNotificationsInbox,
      );
    });
  }

  Widget _buildAppBarLogo() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
      child: Image.asset(
        'assets/images/MissionForNation.png',
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.shield_outlined, color: Color(0xFF4C734D)),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Obx(() {
      final imageUrl = (authService.userProfile['profile_image'] ?? '')
          .toString()
          .trim();

      return CircleAvatar(
        backgroundColor: const Color(0xFFEAEAEA),
        backgroundImage: imageUrl.isNotEmpty
            ? CachedNetworkImageProvider(imageUrl)
            : null,
        child: imageUrl.isEmpty
            ? const Icon(Icons.person, color: Colors.black54)
            : null,
      );
    });
  }

  // --- EXISTING UI WIDGETS (NO CHANGES BELOW) ---

  Widget _buildHorizontalEventSection() {
    return SizedBox(
      height: 250, // Slightly increased for better spacing
      child: Obx(() {
        if (controller.upcomingEvents.isEmpty) {
          return const Center(child: Text("No upcoming events"));
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 20),
          itemCount: controller.upcomingEvents.length,
          itemBuilder: (context, index) {
            return _buildEventCard(controller.upcomingEvents[index]);
          },
        );
      }),
    );
  }

  Widget _buildEventCard(EventModel event) {
    return GestureDetector(
      // FIXED: Using the constant to avoid underscore/hyphen typos
      onTap: () => Get.toNamed(Routes.EVENT_DETAILS, arguments: event),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGE HANDLING ---
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: event.imageUrl.isEmpty
                  ? Image.asset(
                      _eventPlaceholder,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      imageUrl: event.imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Image.asset(
                        _eventPlaceholder,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      placeholder: (context, url) {
                        return Container(
                          height: 150,
                          color: Colors.grey[100],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Color(0xFF4C734D),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${event.day} ${event.month}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4C734D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(route),
            child: const Row(
              children: [
                Text(
                  "See All",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Icon(Icons.chevron_right, color: Colors.grey, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveSection(Widget player) {
    return ClipRRect(borderRadius: BorderRadius.circular(24), child: player);
  }

  Widget _buildFillerBanner() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1515162305285-0293e4767cc2?q=80&w=1000',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: const Center(
        child: Text(
          "Welcome to Church",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _actionItem(
            Icons.play_circle_outline,
            "Sermons",
            () => Get.toNamed(Routes.SERMONS),
          ),
          _actionItem(
            Icons.book_outlined,
            "Books",
            () => Get.toNamed(Routes.STORE),
          ),
          _actionItem(
            Icons.people_outline,
            "Events",
            () => Get.toNamed(Routes.EVENTS),
          ),
          _actionItem(
            Icons.favorite_border,
            "Give",
            () => Get.toNamed(Routes.DONATIONS),
          ),
        ],
      ),
    );
  }

  Widget _actionItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF4C734D)),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonySection() {
    if (controller.testimonies.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          "No testimonies yet.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final items = controller.testimonies.take(4).toList();

    return Column(
      children: items
          .map(
            (testimony) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTestimonyCard(testimony),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTestimonyCard(dynamic testimony) {
    final imageUrl = testimony.images.isNotEmpty
        ? testimony.images.first
        : null;

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.TESTIMONIES),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl.toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 70,
                  width: 100,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Image.asset(
                    'assets/images/testimony_placeholder.jpg',
                    height: 70,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                  placeholder: (_, __) => Container(
                    height: 70,
                    width: 100,
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/testimony_placeholder.jpg',
                  height: 70,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    testimony.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    testimony.verse,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
