class PaymentHistoryResponse {
  final List<BookPurchase> purchases;
  final List<DonationHistory> donations;

  PaymentHistoryResponse({required this.purchases, required this.donations});

  factory PaymentHistoryResponse.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryResponse(
      purchases:
          (json['purchases'] as List?)
              ?.map((e) => BookPurchase.fromJson(e))
              .toList() ??
          [],
      donations:
          (json['donations'] as List?)
              ?.map((e) => DonationHistory.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class BookPurchase {
  final String id;
  final double amount;
  final String status;
  final DateTime date;
  final String bookTitle;
  final String bookCover;

  BookPurchase({
    required this.id,
    required this.amount,
    required this.status,
    required this.date,
    required this.bookTitle,
    required this.bookCover,
  });

  factory BookPurchase.fromJson(Map<String, dynamic> json) => BookPurchase(
    id: json['_id'],
    amount: (json['amount'] ?? 0).toDouble(),
    status: json['status'] ?? 'pending',
    date: DateTime.parse(json['createdAt']),
    bookTitle: json['book']?['title'] ?? 'Unknown Book',
    bookCover: json['book']?['coverImage'] ?? '',
  );
}

class DonationHistory {
  final String id;
  final double amount;
  final String status;
  final DateTime date;
  final String currency;

  DonationHistory({
    required this.id,
    required this.amount,
    required this.status,
    required this.date,
    required this.currency,
  });

  factory DonationHistory.fromJson(Map<String, dynamic> json) =>
      DonationHistory(
        id: json['_id'],
        amount: (json['amount'] ?? 0).toDouble(),
        status: json['status'] ?? 'pending',
        date: DateTime.parse(json['createdAt']),
        currency: json['currency'] ?? 'ETB',
      );
}
