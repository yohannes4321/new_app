import mongoose, { Schema } from "mongoose";
import { IEventRegistrationDocument } from "./event.types.js";

const eventRegistrationSchema = new Schema<IEventRegistrationDocument>(
    {
        event_id: { type: Schema.Types.ObjectId, ref: "Event", required: true },
        user_id: { type: String, required: true },
    },
    {
        timestamps: true,
    },
);

eventRegistrationSchema.index({ event_id: 1, user_id: 1 }, { unique: true });
eventRegistrationSchema.index({ event_id: 1 });

export const EventRegistration = mongoose.model<IEventRegistrationDocument>(
    "EventRegistration",
    eventRegistrationSchema,
);
