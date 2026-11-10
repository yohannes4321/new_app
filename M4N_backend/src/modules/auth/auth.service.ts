import { UserService } from "../users/user.service.js";
import { RegisterInput, IUserResponse } from "../users/user.types.js";
import admin from "../../config/firebase.js";
import { User } from "../users/user.model.js";

export interface AuthResult {
  user: IUserResponse;
  token?: string;
}

export class AuthService {
  /**
   * Register a new user
   */
  static async createUser(data: RegisterInput) {
    // 1. Check if user already exists in MongoDB
    const existingUser = await User.findOne({
      $or: [{ email: data.email }, { username: data.username }],
    });

    if (existingUser) {
      throw new Error("User with this email or username already exists");
    }

    // 2. Create the user record
    const user = new User(data);
    return await user.save();
  }

  /**
   * Verifies a Firebase ID Token and returns the user from our DB
   */
  static async verifySession(idToken: string) {
    try {
      // 1. Verify the token with Firebase Admin
      const decodedToken = await admin.auth().verifyIdToken(idToken);
      const firebaseId = decodedToken.uid;

      // 2. Fetch the full user profile from database using the firebaseId
      const user = await UserService.findByFirebaseId(firebaseId);

      if (!user) {
        throw new Error("Account profile is missing from the database. Registration must be completed.");
      }

      // 3. Return the user (formatted for the response)
      return UserService.toResponse(user);
    } catch (error) {
      console.error("Error verifying session:", error);
      if (error instanceof Error && error.message.startsWith("Account profile is missing")) {
        throw error;
      }
      throw new Error("Invalid or expired token");
    }
  }
  /**
   * Login user
   */
  // static async login(idToken: string): Promise<AuthResult> {
  //   // 1. Verify token with Firebase
  //   const decodedToken = await admin.auth().verifyIdToken(idToken);

  //   // 2. Extract Firebase UID
  //   const firebaseUid = decodedToken.uid;

  //   // 3. Find user in MongoDB using firebase UID
  //   const user = await UserService.findByFirebaseUid(firebaseUid);

  //   if (!user) {
  //     throw new Error("User not registered in system");
  //   }

  //   // 4. Return user profile (NO password, NO JWT)
  //   return {
  //     user: UserService.toResponse(user),
  //   };
  // }

  /**
   * Get user profile by ID
   */
  static async getProfile(userId: string): Promise<IUserResponse> {
    const user = await UserService.findByFirebaseId(userId);
    if (!user) {
      throw new Error("User not found");
    }
    return UserService.toResponse(user);
  }

  /**
   * Generate JWT token
   */
  // private static generateToken(userId: string): string {
  //   return jwt.sign({ userId }, ENV.JWT_SECRET, {
  //     expiresIn: ENV.JWT_EXPIRES_IN as jwt.SignOptions["expiresIn"],
  //   });
  // }

  /**
   * Verify JWT token
   */
  // static verifyToken(token: string): { userId: string } {
  //   return jwt.verify(token, ENV.JWT_SECRET) as { userId: string };
  // }
}
