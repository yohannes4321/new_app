import mongoose, { Schema } from "mongoose";
import { ITestimonyDocument } from "./testimony.types.js";

interface CounterDocument {
  _id: string;
  seq: number;
}

const counterSchema = new Schema<CounterDocument>(
  {
    _id: { type: String, required: true },
    seq: { type: Number, default: 0 },
  },
  { versionKey: false },
);

const Counter = mongoose.model<CounterDocument>("TestimonyCounter", counterSchema);

const testimonyCommentSchema = new Schema(
  {
    user_id: { type: String, required: true },
    posted_by: { type: String, required: true },
    text: { type: String, required: true },
    created_at: { type: Date, default: Date.now },
  },
  { _id: false },
);

const testimonySchema = new Schema<ITestimonyDocument>(
  {
    id: { type: Number, unique: true, index: true },
    title: { type: String, required: true },
    verse: { type: String, default: "" },
    text_content: { type: String, required: true },
    images: {
      type: [String],
      default: [],
    },
    posted_by: { type: String, required: true },
    youtube_video_id: { type: String, required: false },
    likes: { type: [String], default: [] },
    comments: { type: [testimonyCommentSchema], default: [] },
  },
  { timestamps: true },
);

testimonySchema.pre("validate", async function () {
  if (!this.isNew || this.id !== undefined) {
    return;
  }

  const counter = await Counter.findByIdAndUpdate(
    "testimony_id",
    { $inc: { seq: 1 } },
    { new: true, upsert: true, setDefaultsOnInsert: true },
  );

  this.id = counter.seq;
});

testimonySchema.index({ title: "text", verse: "text", text_content: "text", posted_by: "text" });

export const Testimony = mongoose.model<ITestimonyDocument>("Testimony", testimonySchema);
