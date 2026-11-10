import mongoose, { Schema } from "mongoose";
import { PlanStatus, ISubscriptionPlan } from "./plan.types.js";

const planSchema = new Schema<ISubscriptionPlan>(
  {
    name: {
      type: String,
      required: true,
    },

    slug: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },

    price: {
      type: Number,
      required: true,
    },

    currency: {
      type: String,
      default: "ETB",
    },

    durationDays: {
      type: Number,
      required: true,
    },

    description: String,

    status: {
      type: String,
      enum: Object.values(PlanStatus),
      default: PlanStatus.ACTIVE,
      index: true,
    },
  },
  { timestamps: true },
);

export const SubscriptionPlan = mongoose.model<ISubscriptionPlan>(
  "SubscriptionPlan",
  planSchema,
);
