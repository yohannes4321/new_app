export enum PlanStatus {
  ACTIVE = "active",
  INACTIVE = "inactive",
}

export interface ISubscriptionPlan {
  name: string;
  slug: string; // unique identifier (monthly-premium)

  price: number;
  currency: string;

  durationDays: number;

  description?: string;
  status: PlanStatus;

  createdAt: Date;
  updatedAt: Date;
}
