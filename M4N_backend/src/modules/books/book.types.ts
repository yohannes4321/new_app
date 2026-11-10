import { Document } from "mongoose";

export interface IBook extends Document {
  title: string;
  author: string;
  price: number;
  coverImage: string;
  category: string;
  description: string;
  fileUrl: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}
