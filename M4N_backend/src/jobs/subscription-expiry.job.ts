import cron from "node-cron";
import { expireSubscriptionsService } from "../modules/subscriptions/subscription.service.js";

/*
  Runs every day at midnight (UTC)
  Adjust timezone if needed
*/

export const startSubscriptionExpiryJob = () => {
  console.log("Subscription expiry cron job started...");

  cron.schedule(
    "0 0 * * *", // every day at 00:00
    async () => {
      try {
        console.log("Running subscription expiry check...");

        await expireSubscriptionsService();

        console.log(`Expired subscriptions`);
      } catch (error) {
        console.error("Subscription expiry cron failed:", error);
      }
    },
    {
      timezone: "UTC",
    },
  );
};
