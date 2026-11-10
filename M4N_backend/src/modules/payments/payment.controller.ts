import { Request, Response } from "express";
import {
  initializeBookPayment,
  initializeSubscriptionPayment,
} from "./payment.service.js";
import { UserService } from "../users/user.service.js";

const getAuthenticatedCustomer = async (userId: string | undefined) => {
  if (!userId) throw new Error("Authentication is required");

  const user = await UserService.findByFirebaseId(userId);
  if (!user) throw new Error("Account profile not found");

  const names = user.username.trim().split(/\s+/).filter(Boolean);
  return {
    userId,
    email: user.email,
    firstName: names[0] ?? "Church",
    lastName: names.slice(1).join(" ") || "Member",
  };
};

export const initializeBookPaymentController = async (
  req: Request,
  res: Response,
) => {
  const userId = req.userId; // from auth middleware
  const { bookId } = req.params;
  try {
    if (!userId || !bookId) {
      return res.status(400).json({ message: "Authentication and book are required" });
    }

    const customer = await getAuthenticatedCustomer(userId);

    const checkoutUrl = await initializeBookPayment({
      ...customer,
      bookId,
    });

    return res.status(200).json({ checkoutUrl });
  } catch (error) {
    console.error("initializeBookPaymentController error:", error);
    return res.status(500).json({ message: "Failed to initialize payment" });
  }
};
export const initializeSubscriptionPaymentController = async (
  req: Request,
  res: Response,
) => {
  const userId = req.userId; // from auth middleware
  const { planId } = req.params;
  try {
    const customer = await getAuthenticatedCustomer(userId);

    const checkoutUrl = await initializeSubscriptionPayment({
      ...customer,
      planId,
    });

    return res.status(200).json({ checkoutUrl });
  } catch (error) {
    console.error("initializeSubscriptionPaymentController error:", error);
    return res.status(500).json({ message: "Failed to initialize payment" });
  }
};

export default initializeBookPaymentController;
