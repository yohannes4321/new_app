import { Document, Types } from "mongoose";

export interface IPurchase extends Document {
  userId: string; // Reference to the User model
  book: Types.ObjectId; // Reference to the Book model
  paymentRef: string; // This will store your Chapa 'tx_ref'
  amount: number;
  currency: string;
  status: "pending" | "completed" | "failed";
  paidAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}
