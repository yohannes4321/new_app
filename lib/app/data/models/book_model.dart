class BookModel {
  final String id; // Changed from int to String for MongoDB compatibility
  final String title;
  final String author;
  final String price;
  final String imageUrl;
  final String category;
  final String? description;
  bool isPurchased; // Changed to non-final to allow "Syncing"

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.description,
    this.isPurchased = false,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['_id'] ?? json['id']?.toString() ?? '', // Maps MongoDB _id
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      price: json['price']?.toString() ?? '0.00',
      imageUrl: json['coverImage'] ?? json['imageUrl'] ?? '',
      category: json['category'] ?? 'General',
      description: json['description'],
      isPurchased: json['isPurchased'] ?? false, 
    );
  }
}