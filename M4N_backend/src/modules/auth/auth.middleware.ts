import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";
import admin from "../../config/firebase.js";
import { UserService } from "../users/user.service.js";
import { ENV } from "../../config/env.js";

// Extend Express Request to include user
declare global {
  namespace Express {
    interface Request {
      userId?: string;
      userRole?: "user" | "admin";
    }
  }
}

export const authMiddleware = async (
	req: Request,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const authHeader = req.headers.authorization;

		if (!authHeader || !authHeader.startsWith("Bearer ")) {
			res.status(401).json({
				success: false,
				message: "Access denied. No token provided.",
			});
			return;
		}

		const token = authHeader.split(" ")[1];

		// Try JWT first (admin dashboard tokens)
		try {
			const decoded = jwt.verify(token, ENV.JWT_SECRET) as { userId: string; role?: string };
			req.userId = decoded.userId;
			if (decoded.role === "admin") req.userRole = "admin";
			next();
			return;
		} catch {
			// Not a JWT — fall through to Firebase verification
		}

		// Try Firebase ID token
		const decodedToken = await admin.auth().verifyIdToken(token);
		req.userId = decodedToken.uid;
		next();
	} catch (error) {
		res.status(401).json({
			success: false,
			message: "Invalid or expired token",
		});
	}
};

export const adminMiddleware = async (
	req: Request,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const userId = req.userId;
		if (!userId) {
			res.status(401).json({ success: false, message: "Unauthorized" });
			return;
		}

		// JWT auth already verified the role — skip Firebase lookup
		if (req.userRole === "admin") {
			next();
			return;
		}

		// Firebase auth path: verify via Firebase and check DB
		const firebaseUser = await admin.auth().getUser(userId);
		const { UserService } = await import("../users/user.service.js");
		const dbUser = await UserService.findByFirebaseId(firebaseUser.uid);
		if (!dbUser || !dbUser.is_admin) {
			res.status(403).json({
				success: false,
				message: "Forbidden: Admin access required",
			});
			return;
		}

		req.userRole = "admin";
		next();
	} catch (error) {
		res
			.status(500)
			.json({ success: false, message: "Authorization check failed" });
	}
};
