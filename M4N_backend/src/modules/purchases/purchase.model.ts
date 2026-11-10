import mongoose, { Schema } from "mongoose";
import { IPurchase } from "./purchase.types.js";

const PurchaseSchema = new Schema<IPurchase>(
  {
    userId: {
      type: String,
      required: true,
    },
    book: {
      type: Schema.Types.ObjectId,
      ref: "Book",
      required: true,
    },
    amount: {
      type: Number,
      required: true,
    },
    paymentRef: {
      type: String,
      required: true,
      unique: true,
    },
    status: {
      type: String,
      enum: ["pending", "completed", "failed"],
      default: "pending",
    },
    paidAt: Date,
  },
  { timestamps: true },
);
export default mongoose.model("Purchase", PurchaseSchema);
