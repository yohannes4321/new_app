class ApiConstants {
  // Set the deployed cPanel API at build time:
  // flutter build appbundle --dart-define=API_BASE_URL=https://api.example.com/api
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000/api',
  );
  static const books = "/books";
  static const createBook = "/books/create";
  static const liveEndpoint = "/live";

  // Existing endpoints (Keep these for when you migrate others)
  static const homeEndpoint = "/core/home/";
  static const sermonEndpoint = "/sermons/";
  static const eventEndpoint = "/events/";
}
