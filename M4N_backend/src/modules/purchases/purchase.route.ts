import { Router } from "express";
import { getMyLibrary, getAllPurchases } from "./purchase.controller.js";
import { authMiddleware } from "../auth/auth.middleware.js";
import { adminOnly } from "../../middlewares/admin.middleware.js";

const router = Router();

// GET /api/purchase/library
router.get("/library", authMiddleware, getMyLibrary);

// GET /api/purchase/all (admin only)
router.get("/all", authMiddleware, adminOnly, getAllPurchases);

export default router;
