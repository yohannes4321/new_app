import Subscription from "./subscription.model.js";
import { SubscriptionPlan } from "./plan.model.js";
import { SubscriptionStatus } from "./subscription.types.js";
import slugify from "slugify";
import { ISubscriptionPlan } from "./plan.types.js";
import { User } from "../users/user.model.js";

const slugifyFn = (slugify as any).default ? (slugify as any).default : slugify;
const DAY_MS = 24 * 60 * 60 * 1000;

/* ======================================================
   CREATE NEW PLAN (ADMIN)
====================================================== */
export const createPlan = async (planData: Partial<ISubscriptionPlan>) => {
  const base = slugifyFn(planData.name || "plan", {
    lower: true,
    strict: true,
  });
  let slug = base;
  let counter = 0;
  while (await SubscriptionPlan.exists({ slug })) {
    counter += 1;
    slug = `${base}-${counter}`;
  }
  const plan = await SubscriptionPlan.create({ ...planData, slug });
  return plan;
};

/* ======================================================
   GET ALL ACTIVE PLANS
====================================================== */
export const getActivePlans = async () => {
  return SubscriptionPlan.find({ status: "active" }).sort({ price: 1 });
};

/* ======================================================
   GET USER ACTIVE SUBSCRIPTION
====================================================== */
export const getUserActiveSubscription = async (userId: string | undefined) => {
  if (!userId) {
    throw new Error("User ID is required");
  }
  return Subscription.findOne({
    userId,
    status: SubscriptionStatus.ACTIVE,
    endDate: { $gt: new Date() },
  }).populate("plan");
};

/* ======================================================
   CHECK IF USER HAS ACTIVE SUBSCRIPTION
====================================================== */
export const hasActiveSubscription = async (
  userId: string,
): Promise<boolean> => {
  const sub = await Subscription.findOne({
    userId,
    status: SubscriptionStatus.ACTIVE,
    endDate: { $gt: new Date() },
  });

  return !!sub;
};

/* ======================================================
   CANCEL SUBSCRIPTION (DOES NOT REMOVE ACCESS UNTIL END)
====================================================== */
export const cancelSubscription = async (userId: string | undefined) => {
  const sub = await Subscription.findOne({
    userId,
    status: SubscriptionStatus.ACTIVE,
  });

  if (!sub) throw new Error("No active subscription");

  sub.status = SubscriptionStatus.CANCELLED;
  await sub.save();

  return sub;
};

/* ======================================================
   EXPIRE OLD SUBSCRIPTIONS (FOR CRON JOB)
====================================================== */
// services/subscription.service.js

export const expireSubscriptionsService = async () => {
  try {
    const now = new Date();

    // 1. Find active subscriptions that are already expired
    const expiredSubscriptions = await Subscription.find({
      status: "active",
      endDate: { $lt: now },
    });

    if (!expiredSubscriptions.length) {
      console.log("No subscriptions to expire");
      return;
    }

    const subscriptionIds = expiredSubscriptions.map((s) => s._id);
    const userIds = expiredSubscriptions.map((s) => s.userId);

    // 2. Mark subscriptions as expired
    await Subscription.updateMany(
      { _id: { $in: subscriptionIds } },
      { $set: { status: "expired" } },
    );

    // 3. Remove user access (example logic — adjust to your system)
    await User.updateMany(
      { _id: { $in: userIds } },
      { $set: { is_premium: false } },
    );

    console.log(`${subscriptionIds.length} subscriptions expired successfully`);
  } catch (error) {
    console.error("Error expiring subscriptions:", error);
    throw error;
  }
};
