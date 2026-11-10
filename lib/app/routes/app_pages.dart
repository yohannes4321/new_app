import 'package:church_app/app/modules/donations/bindings/donation_binding.dart';
import 'package:church_app/app/modules/donations/views/donation_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:church_app/app/data/services/auth_service.dart';

// 1. Auth Imports (Ensure paths are correct)
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/responsive_sign_in_view.dart';
import '../modules/auth/views/responsive_sign_up_view.dart';
import '../modules/auth/views/verify_email_view.dart';
import '../modules/auth/views/web_verify_email_view.dart';

// 2. Mobile Module Imports
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/view/home_view.dart';
import '../modules/home/view/notifications_view.dart';
import '../modules/sermon/bindings/sermons_binding.dart';
import '../modules/sermon/views/sermons_view.dart';
import '../modules/sermon_details/bindings/sermon_details_binding.dart';
import '../modules/sermon_details/view/sermon_details_view.dart';
import '../modules/subscriptions/bindings/subscription_binding.dart';
import '../modules/subscriptions/views/subscriptions_view.dart';
import '../modules/subscriptions/views/web_subscription_view.dart';
import '../modules/store/bindings/store_binding.dart';
import '../modules/store/views/store_view.dart';
import '../modules/events/bindings/events_binding.dart';
import '../modules/events/views/events_view.dart';
import '../modules/event_details/bindings/event_details_binding.dart';
import '../modules/event_details/views/event_details_view.dart';
import '../modules/testimonies/bindings/testimonies_binding.dart';
import '../modules/testimonies/views/testimonies_view.dart';
import '../modules/store/views/book_reader_view.dart'; // Add this
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/controllers/views/profile_view.dart';
import '../modules/profile/controllers/payment_history_controller.dart';
import '../modules/profile/controllers/views/payment_history_view.dart';

// 3. Web Module Imports
import 'package:church_app/app/modules/web_home/views/web_home_view.dart';
import 'package:church_app/app/modules/web_home/views/web_sermon_detail_view.dart';

import 'app_routes.dart';

class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthService>();
    if (!auth.isLoggedIn.value) {
      return const RouteSettings(name: Routes.SIGN_IN);
    }
    return null;
  }
}

class AppPages {
  // This must use the Routes constant
  static const INITIAL = Routes.SIGN_IN;

  static final routes = [
    // Auth
    GetPage(
      name: Routes.SIGN_IN,
      page: () => const ResponsiveSignInView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.SIGN_UP,
      page: () => const ResponsiveSignUpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.VERIFY_EMAIL,
      page: () => kIsWeb ? const WebVerifyEmailView() : const VerifyEmailView(),
      binding: AuthBinding(),
    ),

    // Mobile
    GetPage(
      name: Routes.HOME,
      page: () => kIsWeb ? const WebHomeView() : const HomeView(),
      bindings: [HomeBinding(), SermonsBinding()],
      middlewares: [AuthGuard()],
      transition: kIsWeb ? Transition.noTransition : Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.SERMON_DETAILS,
      page: () =>
          kIsWeb ? const WebSermonDetailView() : const SermonDetailsView(),
      binding: SermonDetailsBinding(),
    ),
    GetPage(
      name: Routes.SUBSCRIPTIONS,
      page: () =>
          kIsWeb ? const WebSubscriptionView() : const SubscriptionsView(),
      binding: SubscriptionBinding(),
      transition: kIsWeb ? Transition.noTransition : Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.SERMONS,
      page: () => const SermonsView(),
      binding: SermonsBinding(),
    ),
    GetPage(
      name: Routes.STORE,
      page: () => const StoreView(),
      binding: StoreBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: Routes.DONATIONS,
      page: () => const DonationView(),
      binding: DonationBinding(),
    ),
    GetPage(
      name: Routes.EVENTS,
      page: () => const EventsView(),
      binding: EventsBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: Routes.EVENT_DETAILS,
      page: () => const EventDetailsView(),
      binding: EventDetailsBinding(),
    ),
    GetPage(
      name: Routes.TESTIMONIES,
      page: () => const TestimoniesView(),
      binding: TestimoniesBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(name: Routes.NOTIFICATIONS, page: () => const NotificationsView()),
    GetPage(
      name: Routes.PAYMENT_HISTORY,
      page: () => const PaymentHistoryView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PaymentHistoryController>(() => PaymentHistoryController());
      }),
    ),
    GetPage(
      name: Routes.BOOK_READER,
      page: () => const BookReaderView(),
      // No special binding needed, we just pass the URL as an argument
    ),
  ];
}
