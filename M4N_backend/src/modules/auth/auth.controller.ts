import { Request, Response } from "express";
import { AuthService } from "./auth.service.js";
import { UserService } from "../users/user.service.js";
import { RegisterInput, UpdateProfileInput } from "../users/user.types.js";

export class AuthController {
  /**
   * POST /auth/register
   */
  static async register(req: Request, res: Response): Promise<void> {
    try {
      const input: RegisterInput = req.body;

      // Basic validation
      if (
        !input.username ||
        !input.email ||
        !input.password ||
        !input.phone_number
      ) {
        res.status(400).json({
          success: false,
          message: "Please provide username, email, password, and phone_number",
        });
        return;
      }

      // if (input.role) {
      //   res.status(400).json({
      //     success: false,
      //     message: "Role cannot be set during registration",
      //   });
      //   return;
      // }
      const result = await AuthService.createUser(input);

      res.status(201).json({
        success: true,
        message: "User registered successfully",
        data: result,
      });
    } catch (error) {
      const message =
        error instanceof Error ? error.message : "Registration failed";
      res.status(400).json({
        success: false,
        message,
      });
    }
  }

  /**
   * POST /auth/session
   */

  static async manageSession(req: Request, res: Response): Promise<void> {
    try {
      // Accept token from body OR Authorization header
      const authHeader = req.headers.authorization;
      const idToken =
        req.body?.idToken ??
        (authHeader?.startsWith("Bearer ") ? authHeader.slice(7) : undefined);

      if (!idToken) {
        res.status(400).json({ success: false, message: "idToken is required" });
        return;
      }

      const user = await AuthService.verifySession(idToken);

      res.status(200).json({
        success: true,
        message: "Session verified",
        user,
        data: user,
      });
    } catch (error) {
      const message =
        error instanceof Error ? error.message : "Authentication failed";
      res.status(401).json({ success: false, message });
    }
  }

  /**
   * GET /auth/profile
   */
  static async getProfile(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.userId!;
      const user = await AuthService.getProfile(userId);

      res.status(200).json({
        success: true,
        data: user,
      });
    } catch (error) {
      const message =
        error instanceof Error ? error.message : "Failed to get profile";
      res.status(404).json({
        success: false,
        message,
      });
    }
  }

  /**
   * PUT /auth/profile
   */
  static async updateProfile(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.userId!;
      const updateData: UpdateProfileInput = req.body;

      // Only allow updating specific fields
      const allowedFields: UpdateProfileInput = {};
      if (updateData.username) allowedFields.username = updateData.username;
      if (updateData.profile_image)
        allowedFields.profile_image = updateData.profile_image;
      if (updateData.phone_number)
        allowedFields.phone_number = updateData.phone_number;

      const user = await UserService.updateProfile(userId, allowedFields);

      if (!user) {
        res.status(404).json({
          success: false,
          message: "User not found",
        });
        return;
      }

      res.status(200).json({
        success: true,
        message: "Profile updated successfully",
        data: UserService.toResponse(user),
      });
    } catch (error) {
      const message =
        error instanceof Error ? error.message : "Failed to update profile";
      res.status(400).json({
        success: false,
        message,
      });
    }
  }

  /**
   * GET /auth/stats
   * Returns user statistics (for Profile page)
   */
  static async getStats(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.userId!;
      const user = await AuthService.getProfile(userId);

      res.status(200).json({
        success: true,
        data: {
          total_donations: user.total_donations,
          is_premium: user.is_premium,
          events_registered: 0,
        },
      });
    } catch (error) {
      const message =
        error instanceof Error ? error.message : "Failed to get stats";
      res.status(404).json({ success: false, message });
    }
  }

  /**
   * GET /auth/users (admin only)
   * Returns paginated list of all users
   */
  static async getAllUsers(req: Request, res: Response): Promise<void> {
    try {
      const { User } = await import("../users/user.model.js");
      const page = Math.max(1, Number(req.query.page) || 1);
      const limit = Math.min(100, Math.max(1, Number(req.query.limit) || 20));
      const skip = (page - 1) * limit;

      const [users, total] = await Promise.all([
        User.find().select("-password").sort({ createdAt: -1 }).skip(skip).limit(limit),
        User.countDocuments(),
      ]);

      res.status(200).json({
        success: true,
        data: users,
        pagination: { total, page, limit, pages: Math.ceil(total / limit) },
      });
    } catch {
      res.status(500).json({ success: false, message: "Failed to load users" });
    }
  }
}
