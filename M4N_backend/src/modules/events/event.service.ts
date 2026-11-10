import { Event } from "./event.model.js";
import { EventRegistration } from "./event.registration.model.js";
import {
    IEventDocument,
    CreateEventInput,
    UpdateEventInput,
} from "./event.types.js";

export class EventService {
    /**
     * Create a new event
     */
    static async createEvent(input: CreateEventInput): Promise<IEventDocument> {
        const event = new Event(input);
        return event.save();
    }

    /**
     * Get all events (with pagination and filtering)
     */
    static async getAllEvents(options: {
        page?: number;
        limit?: number;
        upcoming?: boolean;
    } = {}): Promise<{ events: IEventDocument[]; total: number }> {
        const { page = 1, limit = 10, upcoming = false } = options;
        const skip = (page - 1) * limit;

        const query: any = {};
        if (upcoming) {
            query.date_time = { $gte: new Date() };
        }

        const [events, total] = await Promise.all([
            Event.find(query)
                .sort({ date_time: 1 })
                .skip(skip)
                .limit(limit),
            Event.countDocuments(query),
        ]);

        return { events, total };
    }

    /**
     * Get a single event by ID
     */
    static async getEventById(id: string): Promise<IEventDocument | null> {
        return Event.findById(id);
    }

    /**
     * Update an event
     */
    static async updateEvent(
        id: string,
        input: UpdateEventInput,
    ): Promise<IEventDocument | null> {
        return Event.findByIdAndUpdate(id, input, {
            new: true,
            runValidators: true,
        });
    }

    /**
     * Delete an event
     */
    static async deleteEvent(id: string): Promise<boolean> {
        const result = await Event.findByIdAndDelete(id);
        return !!result; // Double Banger
    }

    /**
     * Register a user for an event (Atomic update)
     */
    static async registerForEvent(
        eventId: string,
        userId: string
    ): Promise<IEventDocument | null> {
        const check = await Event.findById(eventId);
        if (!check) throw new Error("Event not found");
        if (!check.allows_registration) throw new Error("Registration is not allowed");
        if (check.is_full) throw new Error("Event is already full");

        try {
            await EventRegistration.create({ event_id: check._id, user_id: userId });
        } catch (error: any) {
            if (error?.code === 11000) {
                throw new Error("Already registered");
            }
            throw error;
        }

        const updated = await Event.findByIdAndUpdate(
            eventId,
            { $inc: { registration_count: 1 } },
            { new: true }
        );

        if (!updated) {
            await EventRegistration.deleteOne({ event_id: eventId, user_id: userId });
            throw new Error("Event not found");
        }

        return updated;
    }

    /**
     * Unregister from an event (Atomic update)
     */
    static async unregisterFromEvent(
        eventId: string,
        userId: string
    ): Promise<IEventDocument | null> {
        const removed = await EventRegistration.deleteOne({
            event_id: eventId,
            user_id: userId,
        });

        if (removed.deletedCount === 0) {
            const check = await Event.findById(eventId);
            if (!check) throw new Error("Event not found");
            throw new Error("Not registered");
        }

        const updated = await Event.findOneAndUpdate(
            { _id: eventId, registration_count: { $gt: 0 } },
            { $inc: { registration_count: -1 } },
            { new: true }
        );

        if (!updated) {
            await Event.updateOne({ _id: eventId }, { $set: { registration_count: 0 } });
            return Event.findById(eventId);
        }

        return updated;
    }
}
