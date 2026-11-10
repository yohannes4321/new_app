import Book from "./book.model.js";
import Purchase from "../purchases/purchase.model.js";
import mongoose from "mongoose";

class BookService {
  // Store listing
  static async getAllBooks() {
    return Book.find()
      .select("title author price coverImage category ")
      .sort({ createdAt: -1 });
  }

  // Single book
  static async getBookById(bookId: string | string[]) {
    const bookObjId = new mongoose.Types.ObjectId(bookId as string);
    return Book.findById(bookObjId).select("-fileUrl -__v");
  }
  static async getBookByIdToRead(bookId: string | string[]) {
    const bookObjId = new mongoose.Types.ObjectId(bookId as string);
    return Book.findById(bookObjId).select("-__v");
  }

  // Admin create
  static async createBook(data: any) {
    return Book.create(data);
  }

  // Admin update
  static async updateBook(bookId: string | string[], data: any) {
    return Book.findByIdAndUpdate(bookId, data, { new: true });
  }

  // Admin delete
  static async deleteBook(bookId: string | string[]) {
    return Book.findByIdAndDelete(bookId);
  }

  // Check if user can read book
  static async canUserReadBook(
    userId: string | undefined,
    bookId: string | string[],
  ) {
    const purchase = await Purchase.findOne({
      userId,
      book: bookId,
      status: "completed",
    });

    return !!purchase;
  }
}

export default BookService;
