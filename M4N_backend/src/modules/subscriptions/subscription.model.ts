import mongoose, { Schema, model } from "mongoose";
import { ISubscription, SubscriptionStatus } from "./subscription.types.js";

const subscriptionSchema = new Schema<ISubscription>(
  {
    userId: {
      type: String,
      required: true,
    },

    plan: {
      type: Schema.Types.ObjectId,
      ref: "SubscriptionPlan",
      required: true,
      index: true,
    },

    status: {
      type: String,
      enum: Object.values(SubscriptionStatus),
      required: true,
      default: SubscriptionStatus.PENDING,
      index: true,
    },

    paymentRef: {
      type: String,
      required: true,
      unique: true, // prevents duplicate webhook activation
      index: true,
    },

    amount: {
      type: Number,
      required: true,
    },

    startDate: {
      type: Date,
      index: true,
    },

    endDate: {
      type: Date,
      index: true,
    },
  },
  {
    timestamps: true,
  },
);

const Subscription = model<ISubscription>("Subscription", subscriptionSchema);

export default Subscription;
