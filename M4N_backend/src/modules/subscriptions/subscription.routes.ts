import { Router } from "express";
import {
  getPlansController,
  mySubscriptionController,
  cancelSubscriptionController,
} from "./subscription.controller.js";
import { initializeSubscriptionPaymentController } from "../payments/payment.controller.js";
import { authMiddleware } from "../auth/auth.middleware.js";
import { adminOnly } from "../../middlewares/admin.middleware.js";
import { createPlanController } from "./subscription.controller.js";

const router = Router();

/**
 * Subscription routes:
 * GET /plans - list all active subscription plans
 * POST /:planId/initiate - initiate subscription payment for a plan
 * GET /my-subscription - get current user's active subscription
 * POST /:subscriptionId/cancel - cancel current user's subscription
 * POST /admin/plans - create a new subscription plan (admin only)
 */

router.get("/plans", authMiddleware, getPlansController);
router.post(
  "/:planId/initiate",
  authMiddleware,
  initializeSubscriptionPaymentController,
);
router.get("/my-subscription", authMiddleware, mySubscriptionController);
router.delete(
  "/:subscriptionId/cancel",
  authMiddleware,
  cancelSubscriptionController,
);
router.post("/plans/create", authMiddleware, adminOnly, createPlanController);

export default router;
