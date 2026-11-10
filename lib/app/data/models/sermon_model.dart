import 'package:intl/intl.dart'; // Add 'intl' to your pubspec.yaml

class SermonModel {
  final String id;
  final String title;
  final String pastorName;
  final String rawDate; // Store the original string
  final String imageUrl;
  final String? audioUrl;
  final String slug;
  final bool isPremium;

  SermonModel({
    required this.id, required this.title, required this.pastorName,
    required this.rawDate, required this.imageUrl, this.audioUrl,
    required this.slug, this.isPremium = false,
  });

  // 🔥 NEW: Beautiful Date Formatter
  String get formattedDate {
    try {
      DateTime dt = DateTime.parse(rawDate);
      return DateFormat('MMM d, yyyy').format(dt); // e.g., "May 1, 2024"
    } catch (e) {
      return rawDate;
    }
  }

  factory SermonModel.fromJson(Map<String, dynamic> json) => SermonModel(
    id: json['_id'] ?? '',
    title: json['title'] ?? 'Untitled',
    pastorName: json['pastor_name'] ?? 'Unknown Pastor',
    rawDate: json['date'] ?? '',
    imageUrl: json['cover_image'] ?? '',
    audioUrl: json['audio_file'],
    slug: json['slug'] ?? '',
    isPremium: json['is_premium'] ?? false,
  );
}