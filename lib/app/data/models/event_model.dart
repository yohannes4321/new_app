class EventModel {
  final String id; // MongoDB _id
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final String imageUrl;
  final int regCount;
  final int capacity;
  final bool isFull;
  final bool allowsRegistration;
  bool isUserRegistered; // Non-final so we can toggle it after API call

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.imageUrl,
    required this.regCount,
    required this.capacity,
    this.isFull = false,
    this.allowsRegistration = true,
    this.isUserRegistered = false,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    // Calculate if full based on count vs capacity
    int count = json['registrationCount'] ?? 0;
    int cap = json['capacity'] ?? 0;
    
    return EventModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      // Parsing the ISO date from backend
      dateTime: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      location: json['location'] ?? '',
      imageUrl: json['bannerImage'] ?? '', 
      regCount: count,
      capacity: cap,
      isFull: count >= cap && cap != 0,
      allowsRegistration: true, // You can link this to a backend field if exists
      isUserRegistered: json['is_user_registered'] ?? false,
    );
  }

  String get day => dateTime.day.toString();
  String get month => _monthNames[dateTime.month - 1];

  static const _monthNames = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
}