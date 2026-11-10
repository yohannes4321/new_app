import axios from "axios";
import mongoose, { Types } from "mongoose";
import Purchase from "../purchases/purchase.model.js";
import Book from "../books/book.model.js";
import { SubscriptionPlan } from "../subscriptions/plan.model.js";
import Subscription from "../subscriptions/subscription.model.js";
import { User } from "../users/user.model.js";

interface ChapaVerifyResponse {
  data?: {
    status?: string;
    amount?: number | string;
  };
}
/**
 * ================================
 * INITIALIZE PAYMENT
 * ================================
 * Creates a Chapa checkout session
 * and stores a pending purchase.
 */
export const initializeBookPayment = async (paymentData: {
  email: string;
  firstName: string;
  lastName: string;
  userId: string;
  bookId: string | string[];
}) => {
  try {
    const bookId = Array.isArray(paymentData.bookId)
      ? paymentData.bookId[0]
      : paymentData.bookId;

    const bookObjId = new mongoose.Types.ObjectId(bookId);
    // 1. Get book from database (NEVER trust client price)
    const book = await Book.findById(bookObjId);
    if (!book) {
      throw new Error("Book not found");
    }

    const amount = Number(book.price);

    // 2. Generate unique transaction reference
    const tx_ref = `church-tx-${Date.now()}`;

    // 3. Prepare payload for Chapa
    const payload = {
      amount: amount.toString(),
      currency: "ETB",
      email: paymentData.email,
      first_name: paymentData.firstName,
      last_name: paymentData.lastName,
      tx_ref: tx_ref,

      // Chapa notifies backend here
      callback_url: `${process.env.BASE_URL}/api/payments/book/verify/${tx_ref}`,

      // User browser redirected here
      return_url: process.env.PAYMENT_RETURN_URL || "https://missionfornation.org/payment-result",
    };

    // 4. Call Chapa initialize API
    const response = await axios.post<{ data?: { checkout_url?: string } }>(
      "https://api.chapa.co/v1/transaction/initialize",
      payload,
      {
        headers: {
          Authorization: `Bearer ${process.env.CHAPA_TEST_SECRET_KEY}`,
        },
      },
    );

    const checkoutUrl = response.data?.data?.checkout_url;

    if (!checkoutUrl) {
      throw new Error("Failed to get checkout URL from Chapa");
    }

    // 5. Store pending purchase in database
    await Purchase.create({
      userId: paymentData.userId,
      book: bookObjId,
      amount,
      paymentRef: tx_ref,
      status: "pending",
    });

    // 6. Send checkout link to frontend
    return checkoutUrl;
  } catch (error) {
    console.error("Payment Initialization Error:", error);
    throw new Error("Failed to initialize payment");
  }
};

/**
 * ================================
 * VERIFY PAYMENT
 * ================================
 * Called by Chapa after payment.
 * Confirms payment and unlocks book.
 */
export const verifyBookPayment = async (tx_ref: string | string[]) => {
  try {
    // 1. Find purchase record
    const purchase = await Purchase.findOne({ paymentRef: tx_ref });

    if (!purchase) {
      throw new Error("Purchase not found");
    }

    // Prevent duplicate processing
    if (purchase.status === "completed") {
      return true;
    }

    // 2. Verify with Chapa servers

    const response = await axios.get<ChapaVerifyResponse>(
      `https://api.chapa.co/v1/transaction/verify/${tx_ref}`,
      {
        headers: {
          Authorization: `Bearer ${process.env.CHAPA_TEST_SECRET_KEY}`,
        },
      },
    );

    const paymentStatus = response.data?.data?.status;
    const paidAmount = Number(response.data?.data?.amount);

    // 3. Validate amount matches purchase
    if (paidAmount !== purchase.amount) {
      throw new Error("Payment amount mismatch");
    }

    // 4. Update purchase based on payment result
    if (paymentStatus === "success") {
      await Purchase.updateOne(
        { paymentRef: tx_ref },
        {
          status: "completed",
          paidAt: new Date(),
        },
      );
      return true;
    }

    // If not success → mark failed
    await Purchase.updateOne({ paymentRef: tx_ref }, { status: "failed" });

    return false;
  } catch (error) {
    console.error("Payment Verification Error:", error);
    throw new Error("Payment verification failed");
  }
};

export const initializeSubscriptionPayment = async (paymentData: {
  email: string;
  firstName: string;
  lastName: string;
  planId: string | string[];
  userId: string | undefined;
}) => {
  const plan = await SubscriptionPlan.findById(paymentData.planId);

  if (!plan || plan.status !== "active") {
    throw new Error("Invalid subscription plan");
  }

  const chapaKey =
    process.env.CHAPA_SECRET || process.env.CHAPA_TEST_SECRET_KEY;
  if (!chapaKey) {
    throw new Error("Chapa API key is not configured");
  }

  const tx_ref = `church-sub-${Date.now()}`;
  console.log("Generated tx_ref:", tx_ref);

  const payload = {
    amount: plan.price.toString(),
    currency: plan.currency,
    email: paymentData.email,
    first_name: paymentData.firstName,
    last_name: paymentData.lastName,
    tx_ref,
    callback_url: `${process.env.BASE_URL}/api/payments/subscription/verify/${tx_ref}`,
    return_url: process.env.PAYMENT_RETURN_URL || "https://missionfornation.org/payment-result",
  };

  const response = await axios.post<{ data?: { checkout_url?: string } }>(
    "https://api.chapa.co/v1/transaction/initialize",
    payload,
    { headers: { Authorization: `Bearer ${chapaKey}` } },
  );

  await Subscription.create({
    userId: paymentData.userId,
    plan: plan._id,
    paymentRef: tx_ref,
    amount: plan.price,
    status: "pending",
  });

  return response.data?.data?.checkout_url;
};

export const verifySubscriptionPayment = async (tx_ref: string | string[]) => {
  try {
    const subscription = await Subscription.findOne({ paymentRef: tx_ref });
    const userId = subscription?.userId;

    if (!subscription) throw new Error("Subscription not found");

    // prevent duplicate processing
    if (subscription.status === "active") return true;

    const chapaKey =
      process.env.CHAPA_SECRET || process.env.CHAPA_TEST_SECRET_KEY;
    if (!chapaKey) {
      throw new Error("Chapa API key is not configured");
    }

    const response = await axios.get<ChapaVerifyResponse>(
      `https://api.chapa.co/v1/transaction/verify/${tx_ref}`,
      {
        headers: {
          Authorization: `Bearer ${chapaKey}`,
        },
      },
    );

    const paymentStatus = response.data?.data?.status;
    const paidAmount = Number(response.data?.data?.amount);

    if (paidAmount !== subscription.amount) {
      throw new Error("Subscription amount mismatch");
    }

    if (paymentStatus !== "success") {
      await Subscription.updateOne(
        { paymentRef: tx_ref },
        { status: "failed" },
      );
      return false;
    }

    // ===== ACTIVATE OR EXTEND SUBSCRIPTION =====

    const now = new Date();
    const durationMs = 30 * 24 * 60 * 60 * 1000;

    const existingActive = await Subscription.findOne({
      userId: subscription.userId,
      plan: subscription.plan,
      status: "active",
      endDate: { $gt: now },
    });

    if (existingActive && existingActive.endDate) {
      await Subscription.deleteOne({ _id: subscription._id }); // remove pending record

      existingActive.endDate = new Date(
        existingActive.endDate.getTime() + durationMs,
      );
      existingActive.paymentRef = Array.isArray(tx_ref) ? tx_ref[0] : tx_ref; // update payment ref for renewals

      await existingActive.save();
    } else {
      // activate new subscription
      await Subscription.updateOne(
        { paymentRef: tx_ref },
        {
          status: "active",
          startDate: now,
          endDate: new Date(now.getTime() + durationMs),
        },
      );
    }

    await User.updateOne(
      { firebaseUid: userId },
      { premium_until: new Date(now.getTime() + durationMs), is_premium: true },
    );
    return true;
  } catch (error) {
    console.error("Subscription verification error:", error);
    throw new Error("Subscription verification failed");
  }
};
