import 'package:church_app/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainBottomNav extends StatelessWidget {
  const MainBottomNav({super.key, required this.activeRoute});

  final String activeRoute;

  bool _isActive(String route) => activeRoute == route;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 44),
                onPressed: () => _go(Routes.HOME),
                icon: Icon(
                  Icons.home_outlined,
                  size: 24,
                  color: _isActive(Routes.HOME)
                      ? const Color(0xFF4C734D)
                      : Colors.grey,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 44),
                onPressed: () => _go(Routes.SERMONS),
                icon: Icon(
                  Icons.play_circle_outline,
                  size: 24,
                  color: _isActive(Routes.SERMONS)
                      ? const Color(0xFF4C734D)
                      : Colors.grey,
                ),
              ),
              GestureDetector(
                onTap: () => _go(Routes.DONATIONS),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4C734D),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.spa_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 4,
                      width: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4C734D),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 44),
                onPressed: () => _go(Routes.EVENTS),
                icon: Icon(
                  Icons.people_outline,
                  size: 24,
                  color: _isActive(Routes.EVENTS)
                      ? const Color(0xFF4C734D)
                      : Colors.grey,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 44),
                onPressed: () => _go(Routes.STORE),
                icon: Icon(
                  Icons.book_outlined,
                  size: 24,
                  color: _isActive(Routes.STORE)
                      ? const Color(0xFF4C734D)
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _go(String route) {
    if (Get.currentRoute == route) return;
    Get.toNamed(route);
  }

  static void backOrHome() {
    final navigatorState = Get.key.currentState;
    if (navigatorState != null && navigatorState.canPop()) {
      Get.back();
      return;
    }
    Get.offAllNamed(Routes.HOME);
  }
}
