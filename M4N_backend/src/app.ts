import express from "express";
import cors from "cors";
import authRoutes from "./modules/auth/auth.routes.js";
import eventRoutes from "./modules/events/event.routes.js";
import stripJsonComments from "strip-json-comments";
import sermonRoutes from "./modules/sermon/sermon.routes.js";
import bookRoutes from "./modules/books/book.routes.js";
import paymentRoutes from "./modules/payments/payment.routes.js";
import purchaseRoutes from "./modules/purchases/purchase.route.js";
import subscriptionRoutes from "./modules/subscriptions/subscription.routes.js";
import testimonyRoutes from "./modules/testimonies/testimony.routes.js";

const app = express();

// Middleware
app.use(cors());
app.use(express.text({ type: "application/json" }));

app.use((req, res, next) => {
  if (req.is("application/json") && typeof req.body === "string") {
    try {
      const clean = stripJsonComments(req.body.replace(/^\uFEFF/, ""));
      req.body = JSON.parse(clean);
    } catch (err) {
      return res.status(400).json({ error: "Invalid JSON" });
    }
  }
  next();
});
app.use(express.json());

// // Health check route
app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok", timestamp: new Date().toISOString() });
});

// API Routes
app.use("/api/auth", authRoutes);
app.use("/api/sermons", sermonRoutes);
app.use("/api/books", bookRoutes);
app.use("/api/payments", paymentRoutes);
app.use("/api/purchase", purchaseRoutes);
app.use("/api/subscription", subscriptionRoutes);
app.use("/api/events", eventRoutes);
app.use("/api/testimonies", testimonyRoutes);


// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.method} ${req.url} not found`,
  });
});

app.use(
  (
    err: any,
    req: express.Request,
    res: express.Response,
    next: express.NextFunction,
  ) => {
    console.error("GLOBAL ERROR:", err);
    res.status(500).json({
      message: err.message,
      stack: err.stack,
    });
  },
);

export default app;
