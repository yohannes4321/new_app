import { Router } from "express";
import { TestimonyController } from "./testimony.controller.js";
import { authMiddleware } from "../auth/auth.middleware.js";
import { adminOnly } from "../../middlewares/admin.middleware.js";
import { upload } from "../../middlewares/upload.js";

const router = Router();

// Public
router.get("/", TestimonyController.getTestimonies);
router.get("/search", TestimonyController.searchTestimonies);
router.get("/:id", TestimonyController.getTestimonyById);

// Authenticated
router.post("/:id/like", authMiddleware, TestimonyController.likeTestimony);
router.delete("/:id/like", authMiddleware, TestimonyController.unlikeTestimony);
router.post("/:id/comment", authMiddleware, TestimonyController.commentOnTestimony);

// Admin
router.post("/", authMiddleware, adminOnly, upload.array("images", 10), TestimonyController.createTestimony);
router.put("/:id", authMiddleware, adminOnly, upload.array("images", 10), TestimonyController.updateTestimony);
router.delete("/:id", authMiddleware, adminOnly, TestimonyController.deleteTestimony);

export default router;
