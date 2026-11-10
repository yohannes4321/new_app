import { Router } from "express";
import { SermonController } from "./sermon.controller.js";
import { authMiddleware } from "../auth/auth.middleware.js";
import { upload } from "../../middlewares/upload.js";
import { adminOnly } from "../../middlewares/admin.middleware.js";

const router = Router();

/**
 * categories routes:
 * GET /categories - list all categories
 * POST /categories - create a new category (admin only)
 * PUT /categories/:id - update a category (admin only)
 * DELETE /categories/:id - delete a category (admin only)
 */
router.get("/categories", authMiddleware, SermonController.getAllCategories);
router.post(
  "/categories",
  authMiddleware,
  adminOnly,
  upload.single("image"),
  SermonController.createCategory,
);
router.put(
  "/categories/:id",
  authMiddleware,
  adminOnly,
  upload.single("image"),
  SermonController.updateCategory,
);
router.delete(
  "/categories/:id",
  authMiddleware,
  adminOnly,
  SermonController.deleteCategory,
);

/**
 * sermons routes:
 * GET /sermons - list all sermons in a category
 * GET /sermons/:slug - get sermon details
 * POST /sermons - create a new sermon (admin only)
 * PUT /sermons/:slug - update a sermon (admin only)
 * DELETE /sermons/:slug - delete a sermon (admin only)
 */
router.get("/", authMiddleware, SermonController.getAllSermonsInCatagory);
router.get("/:slug", authMiddleware, SermonController.getOneSermon);
router.post(
  "/create",
  authMiddleware,
  adminOnly,
  upload.fields([
    { name: "cover_image", maxCount: 1 },
    { name: "audio_file", maxCount: 1 },
  ]),
  SermonController.create,
);
router.put(
  "/update/:slug",
  authMiddleware,
  adminOnly,
  upload.fields([
    { name: "cover_image", maxCount: 1 },
    { name: "audio_file", maxCount: 1 },
  ]),
  SermonController.updateSermon,
);
router.delete(
  "/delete/:slug",
  authMiddleware,
  adminOnly,
  SermonController.deleteSermon,
);

export default router;
