import mongoose from "mongoose";
import { ENV } from "./env.js";

export const connectDB = async (): Promise<void> => {
	/**
	 * Connect to MongoDB using Mongoose
	 */
	try {
		await mongoose.connect(ENV.MONGODB_URI);
		console.log("MongoDB connected successfully");
	} catch (error) {
		console.error("MongoDB connection error:", error);
		process.exit(1);
	}
};