import { Request, Response } from "express";
import {
  verifyBookPayment,
  verifySubscriptionPayment,
} from "./payment.service.js";

export const verifyBookPaymentController = async (
  req: Request,
  res: Response,
) => {
  try {
    const tx_ref = req.params.tx_ref;

    const success = await verifyBookPayment(tx_ref);

    if (success) {
      // return res.redirect("http://localhost:3000/payment-success");
      return res.redirect(process.env.PAYMENT_RETURN_URL || "https://missionfornation.org/payment-result?status=success");
    }

    // return res.redirect("http://localhost:3000/payment-failed");
    return res.redirect(process.env.PAYMENT_RETURN_URL || "https://missionfornation.org/payment-result?status=failed");
  } catch (error) {
    console.error("verifyBookPaymentController error:", error);
    // return res.redirect("http://localhost:3000/payment-failed");
    return res.redirect("http://www.google.com/search?q=payment+failed");
  }
};

export const verifySubscriptionController = async (
  req: Request,
  res: Response,
) => {
  console.log(
    "verifySubscriptionController called with tx_ref:",
    req.params.tx_ref,
  );
  try {
    const tx_ref = req.params.tx_ref;

    const success = await verifySubscriptionPayment(tx_ref);

    if (success) {
      return res.redirect(process.env.PAYMENT_RETURN_URL || "https://missionfornation.org/payment-result?status=success");
    }

    return res.redirect(process.env.PAYMENT_RETURN_URL || "https://missionfornation.org/payment-result?status=failed");
  } catch (error) {
    console.error("verifySubscriptionController error:", error);
    return res.redirect(process.env.PAYMENT_RETURN_URL || "https://missionfornation.org/payment-result?status=failed");
  }
};
