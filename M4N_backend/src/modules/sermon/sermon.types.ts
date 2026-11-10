import { Types } from "mongoose";

export interface SermonDocument {
  _id: Types.ObjectId;
  title: string;
  pastor_name: string;
  slug: string;
  category: Types.ObjectId;
  date: Date;
  cover_image: string;
  audio_file?: string;
  is_premium: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateSermonInput {
  title: string;
  pastor_name: string;
  date: string;
  category: string;
  cover_image: string;
  audio_file?: string;
  is_premium: boolean;
}

export interface CategoryDocument {
  name: string;
  imageUrl: string;
  description?: string;
}
