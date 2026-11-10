import { Router } from "express";
import { AuthController } from "./auth.controller.js";
import { authMiddleware } from "./auth.middleware.js";
import { adminOnly } from "../../middlewares/admin.middleware.js";

const router = Router();

// Public routes
router.post("/register", AuthController.register);
router.post("/session", AuthController.manageSession);

// Protected routes (require authentication)
router.get("/profile", authMiddleware, AuthController.getProfile);
router.put("/profile", authMiddleware, AuthController.updateProfile);
router.get("/stats", authMiddleware, AuthController.getStats);

// Admin routes
router.get("/users", authMiddleware, adminOnly, AuthController.getAllUsers);

export default router;
