import { User } from "./user.model.js";
import {
  IUserDocument,
  IUserResponse,
  UpdateProfileInput,
} from "./user.types.js";

export class UserService {
  /**
   * Find user by firebase UID (without password)
   */
  // user.service.ts

  static async findByFirebaseId(
    firebaseUid: string,
  ): Promise<IUserDocument | null> {
    // We use findOne because we are looking for our custom 'id' field,
    // not the Mongoose-generated '_id'
    return User.findOne({ firebaseUid });
  }

  /**
   * Find user by email (includes password for auth)
   */
  static async findByEmail(email: string): Promise<IUserDocument | null> {
    return User.findOne({ email }).select("+password");
  }

  /**
   * Find user by username
   */
  static async findByUsername(username: string): Promise<IUserDocument | null> {
    return User.findOne({ username });
  }

  /**
   * Find user by firebase UID
   */
  static async findByFirebaseUid(firebaseUid: string) {
    return User.findOne({ firebaseUid });
  }

  /**
   * Create a new user
   */
  static async create(userData: {
    id?: string;
    username: string;
    email: string;
    password: string;
    phone_number: string;
    profile_image?: string;
  }): Promise<IUserDocument> {
    const user = new User(userData);
    return user.save();
  }

  /**
   * Update user profile
   */
  static async updateProfile(
    userId: string,
    updateData: UpdateProfileInput,
  ): Promise<IUserDocument | null> {
    return User.findOneAndUpdate({ firebaseUid: userId }, updateData, {
      new: true,
      runValidators: true,
    });
  }

  /**
   * Format user for response (strips sensitive data)
   */
  static toResponse(user: IUserDocument): IUserResponse & { role: string; is_admin: boolean } {
    return {
      id: user.firebaseUid,
      username: user.username,
      email: user.email,
      role: user.role,
      is_admin: user.is_admin,
      is_premium: user.is_premium,
      profile_image: user.profile_image,
      phone_number: user.phone_number,
      total_donations: user.total_donations,
      createdAt: user.createdAt,
    };
  }
}
