import mongoose, { Schema } from "mongoose";
import { IEventDocument } from "./event.types.js";

const eventSchema = new Schema<IEventDocument>({
    title: { type: String, required: true },
    description: { type: String, required: true },
    date_time: { type: Date, required: true },
    location: { type: String, required: true },
    cover_image: { type: String, required: false },
    registration_count: { type: Number, default: 0 },
    is_full: { type: Boolean, default: false },
    allows_registration: { type: Boolean, default: true },
}, {
    timestamps: true,
});

// Indexes for performance
eventSchema.index({ date_time: 1 });
eventSchema.index({ title: "text" }); // Text index for title search

export const Event = mongoose.model<IEventDocument>("Event", eventSchema);