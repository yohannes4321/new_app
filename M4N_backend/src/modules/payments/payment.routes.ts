import { Router } from "express";
import { initializeBookPaymentController } from "./payment.controller.js";
import {
  verifyBookPaymentController,
  verifySubscriptionController,
} from "./webhook.controller.js";
import { authMiddleware } from "../auth/auth.middleware.js";

const router = Router();

router.post("/initialize", authMiddleware, initializeBookPaymentController);
router.get("/book/verify/:tx_ref", verifyBookPaymentController);
router.get("/subscription/verify/:tx_ref", verifySubscriptionController);

export default router;
