import "dotenv/config";
import app from "./app.js";
import { connectDB } from "./config/db.js";
import { ENV } from "./config/env.js";
import { startSubscriptionExpiryJob } from "./jobs/subscription-expiry.job.js";

const startServer = async () => {
  try {
    // Connect to MongoDB
    await connectDB();

    // Start server
    app.listen(ENV.PORT, () => {
      console.log(`Server is running on port ${ENV.PORT}`);
      console.log(`Health check: http://localhost:${ENV.PORT}/health`);
      console.log(`Auth API: http://localhost:${ENV.PORT}/api/auth`);

      // start background jobs
      startSubscriptionExpiryJob();
    });
  } catch (error) {
    console.error("Failed to start server:", error);
    process.exit(1);
  }
};

startServer();
