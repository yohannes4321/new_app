import { Request, Response, NextFunction } from "express";
import { UserService } from "../modules/users/user.service.js";

export const adminOnly = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  if (!req.userId) {
    res.status(401).json({ success: false, message: "Unauthorized" });
    return;
  }

  // JWT auth already verified the role — skip DB lookup
  if (req.userRole === "admin") {
    next();
    return;
  }

  // Firebase auth path: look up by Firebase UID
  const user = await UserService.findByFirebaseId(req.userId);

  if (!user || user.role !== "admin") {
    res.status(403).json({
      success: false,
      message: "Admins only",
    });
    return;
  }

  req.userRole = "admin";
  next();
};
