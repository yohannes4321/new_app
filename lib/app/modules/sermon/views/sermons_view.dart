import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:church_app/app/routes/app_routes.dart';
import 'package:church_app/app/widgets/main_bottom_nav.dart';
import '../../../data/models/sermon_model.dart';
import '../controllers/sermons_controller.dart';

class SermonsView extends GetView<SermonsController> {
  const SermonsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const MainBottomNav(activeRoute: Routes.SERMONS),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Teachings",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryChips(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4C734D)),
                );
              }

              if (controller.filteredSermons.isEmpty) {
                return const Center(
                  child: Text("No sermons found in this category."),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
                itemCount: controller.filteredSermons.length,
                itemBuilder: (context, index) {
                  return _buildSermonGridItem(
                    controller.filteredSermons[index],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Obx(() {
      // 🔥 READ THE DEPENDENCY HERE synchronously so Obx tracks it properly!
      final activeIndex = controller.selectedCategoryIndex.value;

      return Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final cat = controller.categories[index];
            final bool isSelected = activeIndex == index;

            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ChoiceChip(
                label: Text(controller.getCategoryName(cat)),
                selected: isSelected, // This turns the button GREEN
                onSelected: (bool selected) {
                  controller.selectCategoryAt(index);
                },
                selectedColor: const Color(0xFF4C734D),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF4C734D)
                      : Colors.grey[300]!,
                ),
                backgroundColor: Colors.grey[100],
                elevation: isSelected ? 2 : 0,
                pressElevation: 4,
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildSermonGridItem(SermonModel sermon) {
    return GestureDetector(
      onTap: () => controller.onSermonTap(sermon),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: sermon.imageUrl.isEmpty
                        ? Image.asset(
                            'assets/images/testimony_placeholder.jpg',
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            imageUrl: sermon.imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (c, u, e) => Image.asset(
                              'assets/images/testimony_placeholder.jpg',
                              fit: BoxFit.cover,
                            ),
                            placeholder: (c, u) => Container(
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                  ),
                  if (sermon.isPremium)
                    Positioned(top: 8, right: 8, child: _buildLockIcon()),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      sermon.title,
                      maxLines: 2,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sermon.formattedDate,
                          style: const TextStyle(
                            color: Color(0xFF4C734D),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sermon.pastorName,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
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

  Widget _buildLockIcon() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.lock_rounded, color: Colors.amber, size: 14),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: (value) => controller.filterSermons(value),
        decoration: InputDecoration(
          hintText: "Search archives...",
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
