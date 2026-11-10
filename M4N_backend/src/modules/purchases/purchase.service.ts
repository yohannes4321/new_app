import Purchase from "./purchase.model.js";

class PurchaseService {
  // ===============================
  // GET USER LIBRARY
  // ===============================
  static async getUserLibrary(userId: string | undefined) {
    return Purchase.find({
      userId,
      status: "completed",
    })
      .populate("book")
      .select("book") // fetch book info
      .sort({ createdAt: -1 });
  }

  // ===============================
  // CHECK OWNERSHIP
  // ===============================
  static async hasUserPurchasedBook(userId: string, bookId: string) {
    const purchase = await Purchase.findOne({
      userId,
      book: bookId,
      status: "completed",
    });

    return !!purchase; // true or false
  }
}

export default PurchaseService;
