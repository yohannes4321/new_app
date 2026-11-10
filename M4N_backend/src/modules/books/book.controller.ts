import { Request, Response } from "express";
import BookService from "./book.service.js";
import cloudinary from "../../config/cloudinary.js";

/**
 * Helper to extract Public ID from a Cloudinary URL
 * Example: https://res.cloudinary.com/.../v123/books/files/xyz.pdf -> books/files/xyz
 */
const extractPublicId = (url: string): string => {
  if (!url) return "";

  // Look for your specific folder path
  const folderMatch = url.match(/books\/files\/[^.]+/);
  if (folderMatch) {
    return folderMatch[0]; // returns 'books/files/r8hopmyxjrbuelq6qxp0'
  }

  // Fallback for older formats
  const parts = url.split("/");
  return parts[parts.length - 1].split(".")[0];
};

export const getBookViewUrl = (fileUrl: string) => {
  const publicId = extractPublicId(fileUrl);

  // Generate a signed URL using the v2 API
  // Note: Ensure the file was uploaded as resource_type: 'image' and type: 'authenticated'
  return cloudinary.utils.private_download_url(publicId, "pdf", {
    resource_type: "image",
    type: "authenticated",
    expires_at: Math.floor(Date.now() / 1000) + 3600, // 1 hour expiration
    attachment: false, // Ensures browser opens it inline
  });
};

// ================= STORE =================

export class BookController {
  // GET /books
  static async getBooks(req: Request, res: Response) {
    try {
      const books = await BookService.getAllBooks();

      res.json({
        success: true,
        data: books,
      });
    } catch {
      res.status(500).json({ success: false });
    }
  }

  // ================= DETAILS =================

  // GET /books/:id
  static async getBook(req: Request, res: Response) {
    try {
      const book = await BookService.getBookById(req.params.bookId);

      if (!book) {
        return res.status(404).json({ message: "Book not found" });
      }

      res.json({ success: true, data: book });
    } catch {
      res.status(500).json({ success: false });
    }
  }

  // ================= ADMIN CREATE =================

  // POST /books
  static async createBook(req: Request, res: Response) {
    try {
      const files = req.files as
        | {
            coverImage?: Express.Multer.File[];
            file?: Express.Multer.File[];
          }
        | undefined;

      const coverPath = files?.coverImage
        ? files.coverImage[0].path
        : req.body.coverImage;
      const filePath = files?.file
        ? files.file[0].path
        : req.body.fileUrl || req.body.file;

      if (!coverPath || !filePath) {
        return res.status(400).json({
          success: false,
          message: "Both cover image and book file are required",
        });
      }

      const payload = {
        ...req.body,
        coverImage: coverPath,
        fileUrl: filePath,
      };

      const book = await BookService.createBook(payload);

      res.status(201).json({ success: true, data: book });
    } catch (error) {
      res.status(400).json({
        success: false,
        message:
          error instanceof Error ? error.message : "Book creation failed",
      });
    }
  }

  // ================= READ ONLINE =================

  // GET /books/:bookId/read
  static async readBook(req: Request, res: Response) {
    try {
      const userId = req.userId; // Ensure this is populated by your auth middleware
      const bookId = req.params.bookId;

      const canRead = await BookService.canUserReadBook(userId, bookId);

      if (!canRead) {
        return res.status(403).json({
          message: "You must purchase this book first",
        });
      }

      const book = await BookService.getBookByIdToRead(bookId);

      if (!book || !book.fileUrl) {
        return res.status(404).json({ message: "Book file not found" });
      }

      // Pass the fileUrl to the signer, which now extracts the publicId automatically
      const signedUrl = getBookViewUrl(book.fileUrl);

      res.json({
        success: true,
        fileUrl: signedUrl,
      });
    } catch (error) {
      console.error("Read Error:", error);
      res.status(500).json({ success: false });
    }
  }

  // ================= ADMIN UPDATE =================

  // PUT /books/:id
  static async updateBook(req: Request, res: Response) {
    try {
      const files = req.files as
        | {
            coverImage?: Express.Multer.File[];
            file?: Express.Multer.File[];
          }
        | undefined;

      const coverPath = files?.coverImage
        ? files.coverImage[0].path
        : undefined;
      const filePath = files?.file ? files.file[0].path : undefined;

      const payload: any = { ...req.body };

      if (coverPath) payload.coverImage = coverPath;
      if (filePath) payload.fileUrl = filePath;

      const book = await BookService.updateBook(req.params.id, payload);

      if (!book) {
        return res.status(404).json({ message: "Book not found" });
      }

      res.json({ success: true, data: book });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error instanceof Error ? error.message : "Book update failed",
      });
    }
  }

  // ================= ADMIN DELETE =================

  // DELETE /books/:id
  static async deleteBook(req: Request, res: Response) {
    try {
      const book = await BookService.deleteBook(req.params.id);

      if (!book) {
        return res.status(404).json({ message: "Book not found" });
      }

      res.json({ success: true });
    } catch {
      res.status(500).json({ success: false });
    }
  }
}
