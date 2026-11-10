import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:church_app/app/routes/app_routes.dart';
import 'package:church_app/app/widgets/main_bottom_nav.dart';
import '../controllers/store_controller.dart';

class StoreView extends GetView<StoreController> {
  const StoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const MainBottomNav(activeRoute: Routes.STORE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Church Store",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.allBooks.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4C734D)),
          );
        }

        return Column(
          children: [
            _buildVerseHeader(), // The big gradient header
            const SizedBox(height: 24),
            _buildToggleSection(), // The modern pill toggle
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.isCartView.value
                    ? controller.availableBooks.length
                    : controller.purchasedBooks.length,
                itemBuilder: (contsext, index) {
                  final book = controller.isCartView.value
                      ? controller.availableBooks[index]
                      : controller.purchasedBooks[index];
                  return _buildBookItem(book);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildVerseHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 140,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Obx(
              () => Image.network(
                controller.dailyVerseBg.value,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF4C734D)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black38, Colors.black87],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () => Text(
                      "\"${controller.dailyVerse.value}\"",
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(
                    () => Text(
                      controller.dailyVerseRef.value,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
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

  Widget _buildToggleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Container(
        height: 50,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            _toggleBtn(
              "Store",
              controller.isCartView.value,
              () => controller.toggleView(true),
            ),
            _toggleBtn(
              "My Library",
              !controller.isCartView.value,
              () => controller.toggleView(false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookItem(dynamic book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              book.imageUrl,
              height: 90,
              width: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.book, size: 40),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "by ${book.author}",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${book.price}",
                      style: const TextStyle(
                        color: Color(0xFF4C734D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (book.isPurchased)
                      IconButton(
                        tooltip: 'Save offline',
                        onPressed: () => controller.downloadBook(book),
                        icon: const Icon(Icons.download_outlined, color: Color(0xFF4C734D)),
                      ),
                    ElevatedButton(
                      onPressed: () => book.isPurchased
                          ? controller.readBook(book.id)
                          : controller.buyBook(book),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C734D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        book.isPurchased ? "Read Online" : "Buy Now",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: active
                ? [BoxShadow(color: Colors.black12, blurRadius: 4)]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: active ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
