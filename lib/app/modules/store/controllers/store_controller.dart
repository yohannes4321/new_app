import 'package:church_app/app/modules/store/views/payment_webview.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:church_app/app/widgets/app_feedback.dart';
import '../../../data/mock_data.dart';
import '../../../data/models/book_model.dart';
import '../../../data/services/books_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/offline_media_service.dart';

class StoreController extends GetxController {
  final booksRepository = Get.find<BooksRepository>();
  final authService = Get.find<AuthService>();
  final offlineMedia = Get.find<OfflineMediaService>();

  var isCartView = true.obs;
  var isLoading = false.obs;
  var allBooks = <BookModel>[].obs;

  // 🔥 RESTORED: The missing Verse variables for the UI
  var dailyVerse = "".obs;
  var dailyVerseRef = "".obs;
  var dailyVerseBg = "".obs;

  @override
  void onInit() {
    super.onInit();
    _loadDailyVerse(); // Initialize header data
    fetchStoreData(); // Fetch API data
  }

  // Load from Mock for now as discussed for App 8 logic
  void _loadDailyVerse() {
    final verses = MockDatabase.dailyVerseCards;
    if (verses.isNotEmpty) {
      final now = DateTime.now();
      final dayIndex = now.difference(DateTime(now.year, 1, 1)).inDays;
      final selected = verses[dayIndex % verses.length];
      dailyVerse.value = selected['text'] ?? MockDatabase.dailyVerse;
      dailyVerseRef.value = selected['ref'] ?? MockDatabase.dailyVerseRef;
      dailyVerseBg.value = selected['bg'] ?? MockDatabase.dailyVerseBg;
    }
  }

  void fetchStoreData() async {
    isLoading(true);
    try {
      final books = await booksRepository.getBooks();
      allBooks.assignAll(books);
    } catch (e) {
      showAppFeedback('Store Error', e, type: AppFeedbackType.error);
    } finally {
      isLoading(false);
    }
  }

  // Chapa Payment Implementation
  // Chapa Payment Implementation
  Future<void> buyBook(BookModel book) async {
    if (!kIsWeb) {
      showAppFeedback(
        'Already purchased?',
        'Sign in with the account used for your purchase to read your library here.',
        type: AppFeedbackType.info,
      );
      return;
    }

    if (!authService.isLoggedIn.value) {
      showAppFeedback(
        "Auth Required",
        "Please login to buy books",
        type: AppFeedbackType.warning,
      );
      return;
    }

    isLoading(true);
    try {
      final user = authService.userProfile;
      final Map<String, dynamic> payload = {
        "email": user['email'],
        "firstName": user['username'] ?? "Church",
        "lastName": "Member",
      };

      final url = await booksRepository.startPayment(book.id, payload);

      if (url.isNotEmpty) {
        // Stop loading spinner before opening webview
        isLoading(false);

        // 1. OPEN INTERNAL WEBVIEW
        final result = await Get.to(
          () => const PaymentWebView(),
          arguments: url,
        );

        // 2. USER RETURNS FROM CHAPA
        if (result == true) {
          // Show the user we are syncing
          showAppFeedback(
            "Processing",
            "Finalizing your purchase... Please wait a moment.",
            duration: const Duration(seconds: 4),
            type: AppFeedbackType.info,
          );

          isLoading(true); // Turn on spinner so they know it's working

          // 🔥 THE FIX: Give the backend 3 seconds to receive Chapa's webhook
          await Future.delayed(const Duration(seconds: 3));

          // 3. Fetch data again (This hits the Repo to merge Store and Library)
          await booksRepository.getBooks().then((books) {
            // 🔥 THE FIX: Force GetX to recognize the list changed
            allBooks.clear();
            allBooks.assignAll(books);

            showAppFeedback(
              "Success!",
              "${book.title} is now in your Library.",
              type: AppFeedbackType.success,
            );
          });
        }
      }
    } catch (e) {
      showAppFeedback("Payment Error", e, type: AppFeedbackType.error);
    } finally {
      isLoading(false);
    }
  }

  Future<void> readBook(String bookId) async {
    try {
      isLoading(true);
      final signedUrl = await booksRepository.getSecureReadLink(bookId);
      if (signedUrl.isNotEmpty) {
        Get.toNamed('/book-reader', arguments: signedUrl);
      } else {
        showAppFeedback(
          "Access Denied",
          "No readable file URL was returned.",
          type: AppFeedbackType.error,
        );
      }
    } catch (e) {
      showAppFeedback(
        "Access Denied",
        "Could not open this book right now. Please try again.",
        type: AppFeedbackType.error,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> downloadBook(BookModel book) async {
    if (!book.isPurchased) {
      showAppFeedback('Access denied', 'Purchase access before downloading this book.', type: AppFeedbackType.warning);
      return;
    }
    try {
      isLoading(true);
      final signedUrl = await booksRepository.getSecureReadLink(book.id);
      await offlineMedia.download(url: signedUrl, id: 'book_${book.id}', extension: 'pdf');
      showAppFeedback('Saved for offline use', 'This book is now available in My Library.', type: AppFeedbackType.success);
    } catch (e) {
      showAppFeedback('Download failed', e, type: AppFeedbackType.error);
    } finally {
      isLoading(false);
    }
  }

  List<BookModel> get purchasedBooks =>
      allBooks.where((b) => b.isPurchased).toList();
  List<BookModel> get availableBooks =>
      allBooks.where((b) => !b.isPurchased).toList();
  void toggleView(bool val) => isCartView.value = val;
}
