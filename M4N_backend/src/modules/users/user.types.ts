import { Document } from "mongoose";

export interface IUser {
  firebaseUid: string;
  username: string;
  email: string;
  password: string;
  role: "user" | "admin";
  is_premium: boolean;
  premium_until?: Date;
  is_admin: boolean;
  profile_image?: string;
  phone_number: string;
  total_donations: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface IUserDocument extends IUser, Document {
  comparePassword(candidatePassword: string): Promise<boolean>;
}

export interface IUserResponse {
  id: string;
  username: string;
  email: string;
  is_premium: boolean;
  profile_image?: string;
  phone_number: string;
  total_donations: number;
  createdAt: Date;
}

export interface RegisterInput {
  firebaseUid?: string;
  username: string;
  email: string;
  role?: "user" | "admin";
  password: string;
  phone_number: string;
  profile_image?: string;
}

export interface LoginInput {
  email: string;
  password: string;
}

export interface UpdateProfileInput {
  username?: string;
  profile_image?: string;
  phone_number?: string;
}
