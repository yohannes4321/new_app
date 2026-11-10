import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../sermon/controllers/sermons_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../data/services/auth_service.dart';

class WebHomeView extends GetView<SermonsController> {
  const WebHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = context.width;
    final bool isSmallScreen = width < 900;

    // 🔥 DYNAMIC COLUMN LOGIC
    int crossAxisCount = 4;
    if (width < 1200 && width >= 900) crossAxisCount = 3;
    if (width < 900) crossAxisCount = 2;

    return Scaffold(
      backgroundColor: const Color(0xFF121216),
      drawer: isSmallScreen ? Drawer(child: _buildSidebar(context)) : null,
      body: Row(
        children: [
          // 1. Sidebar - Visible only on large screens
          if (!isSmallScreen) _buildSidebar(context),

          // 2. Main Body
          Expanded(
            child: Column(
              children: [
                _buildWebHeader(context, isSmallScreen),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Home",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildWebCategoryChips(),
                        const SizedBox(height: 24),

                        // Responsive Grid with Fixed Count
                        Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.blue,
                              ),
                            );
                          }

                          if (controller.filteredSermons.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 28,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C1C22),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.06),
                                ),
                              ),
                              child: const Text(
                                "No sermons found in this category.",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.filteredSermons.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  crossAxisCount, // 🔥 4, 3, or 2 based on size
                              crossAxisSpacing: 25,
                              mainAxisSpacing: 35,
                              childAspectRatio:
                                  0.85, // Adjusted for better card fit
                            ),
                            itemBuilder: (context, index) {
                              return _buildSermonWebCard(
                                controller.filteredSermons[index],
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebCategoryChips() {
    return Obx(() {
      final activeIndex = controller.selectedCategoryIndex.value;

      return SizedBox(
        height: 48,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            final isSelected = activeIndex == index;

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ChoiceChip(
                label: Text(controller.getCategoryName(category)),
                selected: isSelected,
                onSelected: (_) => controller.selectCategoryAt(index),
                selectedColor: const Color(0xFFD4AF37),
                backgroundColor: const Color(0xFF1C1C22),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFFD4AF37)
                      : Colors.white.withOpacity(0.10),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildWebHeader(BuildContext context, bool isSmallScreen) {
    final authService = Get.find<AuthService>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        children: [
          if (isSmallScreen)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),

          Expanded(
            flex: 2,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  onChanged: (val) => controller.filterSermons(val),
                  decoration: const InputDecoration(
                    hintText: "Search archives...",
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          Obx(() {
            bool loggedIn = authService.isLoggedIn.value;

            if (!isSmallScreen) {
              return Row(
                children: [
                  if (!loggedIn)
                    TextButton(
                      onPressed: () => Get.toNamed(Routes.SIGN_UP),
                      child: const Text(
                        "Register",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (loggedIn) {
                        Get.toNamed(Routes.PROFILE);
                      } else {
                        Get.toNamed(Routes.SIGN_IN);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: loggedIn
                          ? const Color(0xFFD4AF37)
                          : const Color(0xFF1A73E8),
                    ),
                    child: Text(
                      loggedIn ? "Profile" : "Login",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            } else {
              // Small screen icon logic
              return IconButton(
                icon: Icon(
                  loggedIn ? Icons.person : Icons.login,
                  color: Colors.white,
                ),
                onPressed: () {
                  loggedIn
                      ? Get.toNamed(Routes.PROFILE)
                      : Get.toNamed(Routes.SIGN_IN);
                },
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFF18181C),
      child: Column(
        children: [
          const SizedBox(height: 50),
          Image.asset('assets/images/MissionForNation.png', height: 80),
          const SizedBox(height: 10),
          const Text(
            "Mission For Nation",
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 50),

          // SIDEBAR MENU
          _sidebarItem(
            Icons.home_filled,
            "Home",
            Get.currentRoute == Routes.HOME,
            () => _goToWebRoute(Routes.HOME),
          ),

          // 🔥 NEW: Manage Subscription Item
          _sidebarItem(
            Icons.workspace_premium,
            "Manage Subscription",
            false,
            () => _goToWebRoute(Routes.SUBSCRIPTIONS),
          ),
        ],
      ),
    );
  }

  void _goToWebRoute(String route) {
    if (Get.currentRoute == route) return;
    Get.offNamed(route);
  }

  Widget _sidebarItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.grey, size: 20),
            const SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSermonWebCard(dynamic sermon) {
    return InkWell(
      onTap: () => Get.toNamed(Routes.SERMON_DETAILS, arguments: sermon),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: sermon.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade900,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade900,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.white54),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 15,
                  left: 15,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            sermon.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sermon.pastorName,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
