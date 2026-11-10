import { Request, Response } from "express";
import {
  getActivePlans,
  getUserActiveSubscription,
  cancelSubscription,
  createPlan,
} from "./subscription.service.js";
/* ======================================================
   ADMIN: CREATE PLAN
====================================================== */
export const createPlanController = async (req: Request, res: Response) => {
  if (!req.body.name || !req.body.price || !req.body.durationDays) {
    return res.status(400).json({
      success: false,
      message: "Missing required plan fields",
    });
  }

  try {
    const plan = await createPlan(req.body);
    res.status(201).json({ success: true, data: plan });
  } catch (error: any) {
    res.status(400).json({ success: false, message: error.message });
  }
};

/* ======================================================
   GET AVAILABLE PLANS
====================================================== */
export const getPlansController = async (_req: Request, res: Response) => {
  try {
    const plans = await getActivePlans();
    res.json({ success: true, data: plans });
  } catch (error) {
    res.status(500).json({ message: "Failed to load plans" });
  }
};

/* ======================================================
   GET MY SUBSCRIPTION
====================================================== */
export const mySubscriptionController = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;

    const subscription = await getUserActiveSubscription(userId);

    res.json({
      success: true,
      data: subscription,
    });
  } catch (error) {
    error instanceof Error
      ? res.status(400).json({ message: error.message })
      : res.status(500).json({ message: "Failed to fetch subscription" });
  }
};

/* ======================================================
   CANCEL SUBSCRIPTION
====================================================== */
export const cancelSubscriptionController = async (
  req: Request,
  res: Response,
) => {
  try {
    const userId = req.userId;

    const sub = await cancelSubscription(userId);

    res.json({
      success: true,
      message: "Subscription cancelled",
      data: sub,
    });
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
};
