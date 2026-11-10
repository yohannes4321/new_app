import { Router } from "express";
import { BookController } from "./book.controller.js";
import { authMiddleware } from "../auth/auth.middleware.js";
import { adminOnly } from "../../middlewares/admin.middleware.js";
import { upload } from "../../middlewares/upload.js";
import { initializeBookPaymentController } from "../payments/payment.controller.js";

const router = Router();
/**
 * Books routes:
 * GET /books - list all books
 * GET /books/:id - get book details
 * GET /books/:id/read - read book content (protected)
 * POST /books/:id/buy - buy a book (protected)
 */
router.get("/", BookController.getBooks);
router.get("/:bookId", BookController.getBook);
router.get("/:bookId/read", authMiddleware, BookController.readBook);
router.post("/:bookId/buy", authMiddleware, initializeBookPaymentController);

/**
 * Admin routes:
 * POST /books/create - create a new book
 * PUT /books/:id - update a book
 * DELETE /books/:id - delete a book
 */
router.post(
  "/create",
  authMiddleware,
  adminOnly,
  upload.fields([
    { name: "coverImage", maxCount: 1 },
    { name: "file", maxCount: 1 },
  ]),
  BookController.createBook,
);
router.put(
  "/update/:id",
  authMiddleware,
  adminOnly,
  upload.fields([
    { name: "coverImage", maxCount: 1 },
    { name: "file", maxCount: 1 },
  ]),
  BookController.updateBook,
);
router.delete(
  "/delete/:id",
  authMiddleware,
  adminOnly,
  BookController.deleteBook,
);

export default router;
