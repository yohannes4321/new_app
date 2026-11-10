import 'package:get/get.dart';
import '../../../data/models/payment_history_model.dart';
import '../../../data/services/profile_repository.dart';

class PaymentHistoryController extends GetxController {
  final repository = Get.find<ProfileRepository>();

  var isLoading = true.obs;
  var purchases = <BookPurchase>[].obs;
  var donations = <DonationHistory>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  void fetchHistory() async {
    isLoading(true);
    try {
      final history = await repository.getPaymentHistory();
      if (history != null) {
        final sortedPurchases = List<BookPurchase>.from(history.purchases)
          ..sort((a, b) => b.date.compareTo(a.date));
        final sortedDonations = List<DonationHistory>.from(history.donations)
          ..sort((a, b) => b.date.compareTo(a.date));

        purchases.assignAll(sortedPurchases);
        donations.assignAll(sortedDonations);
      }
    } finally {
      isLoading(false);
    }
  }
}
