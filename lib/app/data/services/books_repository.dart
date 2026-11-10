import 'package:get/get.dart';
import '../models/book_model.dart';
import 'books_service.dart';
import 'auth_service.dart';

class BooksRepository {
  final BooksService _service = Get.find<BooksService>();
  final AuthService _auth = Get.find<AuthService>();

  Future<List<BookModel>> getBooks() async {
    try {
      // 1. Fetch Store List
      final storeRes = await _service.getAllBooks();
      if (storeRes.hasError) throw Exception("Failed to load store.");

      final List storeData = storeRes.body['data'] ?? [];
      List<BookModel> allBooks = storeData
          .map((json) => BookModel.fromJson(json))
          .toList();

      // 2. Fetch Personal Library
      if (_auth.isLoggedIn.value) {
        final libRes = await _service.getLibrary(_auth.authToken);

        if (libRes.isOk && libRes.body['data'] != null) {
          final List libraryItems = libRes.body['data'];

          // 🔥 NORMALIZE IDs: Ensure we compare strings to strings
          final ownedIds = libraryItems
              .map((item) => item['book']?['_id']?.toString().trim())
              .whereType<String>()
              .toList();

          print("--- 📚 SYNC LOG ---");
          print("Owned IDs found in Backend: $ownedIds");

          for (var book in allBooks) {
            if (ownedIds.contains(book.id.trim())) {
              book.isPurchased = true;
              print("✅ Match Found: ${book.title}");
            }
          }
        }
      }
      return allBooks;
    } catch (e) {
      print("❌ REPO ERROR: $e");
      rethrow;
    }
  }

  // Initialize Book Payment
  Future<String> startPayment(
    String bookId,
    Map<String, dynamic> paymentData,
  ) async {
    final res = await _service.initializePayment(
      bookId,
      paymentData,
      _auth.authToken,
    );
    if (res.isOk) {
      return res.body['checkoutUrl'] ?? res.body['data']?['checkoutUrl'] ?? "";
    }
    throw Exception(res.body['message'] ?? "Payment failed to start.");
  }

  // Get Secure PDF Link
  Future<String> getSecureReadLink(String bookId) async {
    final res = await _service.getReadUrl(bookId, _auth.authToken);
    if (res.isOk) {
      return res.body['fileUrl'] ?? res.body['data']?['fileUrl'] ?? "";
    }
    throw Exception(res.body['message'] ?? "Access denied.");
  }
}
