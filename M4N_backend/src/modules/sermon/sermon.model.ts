import mongoose, { Schema } from "mongoose";
import { CategoryDocument, SermonDocument } from "./sermon.types.js";

const sermonSchema = new Schema<SermonDocument>(
  {
    title: { type: String, required: true },
    pastor_name: { type: String, required: true },
    date: { type: Date, required: true },
    slug: { type: String, required: true, unique: true, index: true },
    category: {
      type: Schema.Types.ObjectId,
      ref: "Category",
      required: true,
      index: true,
    },
    cover_image: { type: String, required: true },
    audio_file: { type: String },
    is_premium: { type: Boolean, default: false },
  },
  { timestamps: true },
);

const categorySchema = new Schema<CategoryDocument>(
  {
    name: { type: String, required: true, unique: true },
    imageUrl: { type: String, required: true },
    description: { type: String },
  },
  { timestamps: true },
);

export const SermonModel = mongoose.model<SermonDocument>(
  "Sermon",
  sermonSchema,
);

export const CategoryModel = mongoose.model<CategoryDocument>(
  "Category",
  categorySchema,
);
