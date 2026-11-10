class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final int durationDays;
  final String currency;
  final String description;

  SubscriptionPlan({
    required this.id, required this.name, required this.price,
    required this.durationDays, required this.currency, required this.description,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) => SubscriptionPlan(
    id: json['_id'] ?? '',
    name: json['name'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    durationDays: json['durationDays'] ?? 30,
    currency: json['currency'] ?? 'ETB',
    description: json['description'] ?? '',
  );
}