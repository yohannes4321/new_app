import 'package:get/get.dart';
import '../api_constants.dart';

class BooksService extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = ApiConstants.baseUrl;
    httpClient.timeout = const Duration(seconds: 30);
    httpClient.defaultContentType = 'application/json';
    super.onInit();
  }

  // GET /api/books (Public)
  Future<Response> getAllBooks() => get("/books");

  // GET /api/purchase/library (Protected)
  Future<Response> getLibrary(String token) =>
      get("/purchase/library", headers: {'Authorization': 'Bearer $token'});

  // POST /api/books/:id/buy (Protected)
  Future<Response> initializePayment(String bookId, Map data, String token) =>
      post(
        "/books/$bookId/buy",
        data,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        contentType: 'application/json',
      );

  // GET /api/books/{id}/read (Protected - Returns Signed URL)
  Future<Response> getReadUrl(String id, String token) =>
      get("/books/$id/read", headers: {'Authorization': 'Bearer $token'});
}
