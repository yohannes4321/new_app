import { Types } from "mongoose";

export enum SubscriptionStatus {
  PENDING = "pending",
  ACTIVE = "active",
  EXPIRED = "expired",
  CANCELLED = "cancelled",
  FAILED = "failed", // used when renewal payment processed
}

export interface ISubscription {
  userId: string;

  plan: Types.ObjectId;

  status: SubscriptionStatus;

  paymentRef: string;

  amount: number;

  startDate?: Date;
  endDate?: Date;

  createdAt: Date;
  updatedAt: Date;
}
